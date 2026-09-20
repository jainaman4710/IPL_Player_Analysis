# RR Pre-Auction Strategy Dashboard

An IPL player-evaluation dashboard built for Rajasthan Royals' pre-auction
strategy. It is a static site built with the classic open-source
[Evidence](https://evidence.dev) engine (markdown + SQL → static site),
reading from a Neon Postgres database and deployed to Cloudflare Workers.

- **Live site:** https://ipl-player-analysis.amantater026.workers.dev/
- **Data:** Neon project `floral-recipe-26705265`, database `neondb`
- **Coverage:** IPL 2025 and 2026 seasons (contracts, rosters, ball-by-ball
  derived evaluation)

Evidence's default template now pushes toward "Evidence Studio" (a newer, paid
hosted platform). This project deliberately uses the classic self-hostable
engine directly instead, which is free and deploys as a plain static site.

## How it works

```
Neon Postgres views (v_*)
        │   one `select * from v_...` file per view in sources/neon/
        ▼
npm run sources      → extracts each file's result into local Parquet
        ▼
pages/*.md           → markdown + SQL (DuckDB) + Evidence components
        ▼
npm run build        → static site in .evidence/template/build
        ▼
npx wrangler deploy  → Cloudflare Workers (static assets)
```

All modelling lives in Postgres views, not in this repo. Pages only filter,
aggregate and present what the views expose. Dashboard access uses a dedicated
read-only role (`dashboard_reader`, `SELECT` only).

## Pages

| Page | File | Purpose |
|---|---|---|
| Home | `pages/index.md` | Decision framework: how to read the evaluation axes together |
| Batting | `pages/batting.md` | Batting evaluation, filterable |
| Bowling | `pages/bowling.md` | Bowling evaluation, filterable |
| Fielding | `pages/fielding.md` | Fielding evaluation with whole-career leaders |
| SAV | `pages/sav.md` | Situation-Aware Value |
| MVP | `pages/mvp.md` | MVP points, an attempt to replicate the published MVP methodology |
| Compare | `pages/compare.md` | Side-by-side comparison of up to three players across all axes |
| Teams 2025 / 2026 | `pages/teams/2025.md`, `pages/teams/2026.md` | Rosters by team, contracts, role scarcity |

Aura is intentionally not a page. The finalized 10-player list lives untouched
in the `dim_player_aura_flag` table and only surfaces as a flag on the roster
view.

## Repository layout

```
.
├── .node-version                 pins Node 22 for the build environment
├── .npmrc                        legacy-peer-deps=true
├── package.json / package-lock.json
├── patches/                      patch-package patch for @evidence-dev/universal-sql
├── wrangler.jsonc                Cloudflare Workers config (serves .evidence/template/build)
├── evidence.config.yaml
├── sources/neon/
│   ├── connection.yaml           host/database (not secret)
│   ├── connection.options.yaml.template
│   └── *.sql                     one `select * from v_...` per source
└── pages/
    ├── index.md, batting.md, bowling.md, fielding.md, sav.md, mvp.md, compare.md
    └── teams/2025.md, 2026.md
```

Source files and the views they read:

| `neon.<name>` | Postgres view |
|---|---|
| `batting_fact_grain` | `v_batting_fact_grain` |
| `bowling_fact_grain` | `v_bowling_fact_grain` |
| `bowler_type` | `v_bowler_type` |
| `fielding_evaluation` | `v_fielding_evaluation` |
| `fielding_fact_grain` | `v_fielding_fact_grain` |
| `mvp_filterable` | `v_mvp_filterable` |
| `sav_filterable` | `v_sav_filterable` |
| `team_roster` | `v_team_roster` |

## Local setup

Requires Node 22 (see `.node-version`).

1. `npm install`
   (`.npmrc` sets `legacy-peer-deps=true`, which is needed because Evidence's
   peer dependency chain has a known conflict. The `postinstall` hook runs
   `patch-package`; see the patch note below.)
2. Configure the Neon connection:
   - `sources/neon/connection.yaml` already holds the (non-secret) host and
     database.
   - Copy `sources/neon/connection.options.yaml.template` to
     `sources/neon/connection.options.yaml` and fill in the
     `dashboard_reader` username and password, **base64-encoded**. This file
     holds credentials and must never be committed.
3. `npm run sources` pulls data from Neon into local Parquet files.
4. `npm run dev` starts a local dev server to preview while editing.
5. `npm run build` produces the static site (`build:strict` fails on any
   query error; `preview` serves the built output).

## Adding or changing a page

**Sources are extracted per file.** For a live database connector like
Postgres, a page cannot query a database view by its real name. Add a `.sql`
file under `sources/neon/` containing the query (for example
`sources/neon/team_roster.sql` containing `select * from v_team_roster`).
`npm run sources` extracts that file's result, addressable in pages as
`neon.<filename_without_extension>`. Referencing a raw view name in a page
fails with a "table does not exist" error even though `npm run sources`
reports success.

Every `.md` file in `pages/` becomes a page and appears in the sidebar. Pages
are markdown with embedded ` ```sql name ``` ` blocks plus Evidence
components (`<DataTable>`, `<BigValue>`, `<Dropdown>`, and so on).

### Rules learned the hard way

Each of these caused a real build failure or a broken page.

- **Only `SELECT` files in `sources/`.** Any non-SELECT `.sql` file there
  breaks the sources step. Do not commit migration or correction scripts
  into it.
- **Chain queries with `${query_name}`.** A bare query name inside SQL is not
  resolved; it must be written `${query_name}`.
- **No `||` inside markdown tables.** It is parsed as JavaScript and produces
  an `Unterminated regular expression` build error. `compare.md` uses a raw
  HTML `<table>` for this reason.
- **Do not use `rowLinks`.** It broke every table it was added to.
- **No templated player-profile pages.** `pages/players/[player_name].md` and
  `queries/players.sql` were an abandoned attempt that caused a real build
  failure; neither should exist.
- **Set `downloadable=false` on every `<DataTable>`.**
- **Captain and keeper flags are season-scoped.** Use
  `is_captain_2025` / `is_captain_2026` and
  `is_wicketkeeper_2025` / `is_wicketkeeper_2026` from `team_roster`.
- **Confirm with a real build log.** `npm run sources` succeeding, or a page
  rendering something, is not proof that the site builds end to end. Run
  `npm run build` and read the output.

## Deployment

### Cloudflare Workers (production)

- Config: `wrangler.jsonc` serves `./.evidence/template/build` as static
  assets.
- The build must run `npm run sources && npm run build` before
  `npx wrangler deploy`.
- Node 22 comes from `.node-version`; `legacy-peer-deps` from `.npmrc`.
- Set these environment variables in the Cloudflare build environment
  (same values as `connection.options.yaml`, base64-encoded):
  - `EVIDENCE_SOURCE__neon__user`
  - `EVIDENCE_SOURCE__neon__password`

**DuckDB-WASM patch:** the default DuckDB-WASM binaries exceed Cloudflare's
25 MB per-file asset limit. `patches/@evidence-dev+universal-sql+3.0.1.patch`
makes the browser client load DuckDB-WASM from the jsDelivr CDN instead of
bundling it. Do not delete the patch, and keep the filename exactly as is
(hyphens and `+` matter). Upgrading `@evidence-dev/universal-sql` requires
regenerating it.

### Netlify (secondary)

Netlify was previously used and has a matching configuration: build command
`npm install --legacy-peer-deps && npm run sources && npm run build`, publish
directory `.evidence/template/build`, same two environment variables. Its
current state has not been re-verified, so do not assume it serves the same
build as Cloudflare.

## Pinned versions

Evidence packages are pinned to exact versions in `package.json`
(`evidence` 40.1.8, `core-components` 5.4.2, `postgres` 1.0.10,
`duckdb` 2.0.1, `universal-sql` 3.0.1). Change them deliberately, since the
DuckDB-WASM patch is tied to `universal-sql` 3.0.1.

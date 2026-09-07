# RR Pre-Auction Strategy Dashboard

Built with the classic open-source Evidence engine (`@evidence-dev/evidence`,
markdown + SQL → static site), reading from the Neon Postgres project
`floral-recipe-26705265`.

**Status: first draft complete.** All 7 evaluation categories are live —
Career-Level Flags, Batting, Bowling, Fielding, SAV, MVP, Role Scarcity.
Aura is not a page (the finalized 10-player list lives untouched in
`dim_player_aura_flag`). Every page is backed by a verified Neon view;
see each page's own text for the specific judgment calls made where the
spec had gaps (engagement-band labels, batting-role cutoffs, etc.) — these
are the natural starting points for the next round of changes.

Note: Evidence's own default template now pushes toward "Evidence Studio"
(a newer, paid hosted platform). This project deliberately uses the classic
self-hostable engine directly instead — genuinely free, deploys as a static
site to Netlify.

## Local setup

1. `npm install --legacy-peer-deps`
   (`--legacy-peer-deps` is required — Evidence's own peer dependency chain
   has a known conflict as of this writing, unrelated to this project.)
2. Set up your Neon connection:
   - Edit `sources/neon/connection.yaml` — replace `REPLACE_WITH_YOUR_NEON_HOST`
     and `REPLACE_WITH_YOUR_NEON_DATABASE` with your actual Neon host and
     database name (find these in your Neon console — NOT secret, safe to
     commit).
   - Copy `sources/neon/connection.options.yaml.template` to
     `sources/neon/connection.options.yaml` (same folder) and fill in your
     actual Neon username/password, base64-encoded. This file is gitignored —
     it will never be committed.
3. `npm run sources` — pulls data from Neon into local Parquet files.
4. `npm run dev` — starts a local dev server (default `localhost:3000`) to
   preview the dashboard as you edit.

## Adding a new page

**Important, confirmed the hard way:** for a live database connector like Postgres
(unlike CSV), Evidence does NOT let a page query a database table/view by its real
name directly. You must first add a `.sql` file under `sources/neon/` containing
the query to run against Postgres (e.g. `sources/neon/player_career_flags.sql`
containing `select * from v_player_career_flags`). `npm run sources` extracts
*that* file's result into local cache, addressable in pages as
`neon.<sql_filename_without_extension>` — e.g. `select * from neon.player_career_flags`.
Referencing the raw Postgres view name directly in a page (`select * from
v_player_career_flags`) will fail with a "table does not exist" Catalog Error,
even though `npm run sources` reports success (it simply extracts nothing if no
matching `.sql` file exists).

Every `.md` file in `pages/` becomes a page automatically, navigable from the
sidebar. Each page is markdown with embedded ` ```sql name ... ``` ` blocks —
either querying an extracted source table (`neon.something`) or chaining off
another query on the same page via `${other_query_name}` — plus Evidence
components (`<DataTable>`, `<BigValue>`, `<Grid>`, etc.) to render the results.

## Deployment (Netlify)

See deployment instructions from Claude — summary: push this repo to GitHub,
connect it to Netlify, set the Neon credentials as Netlify environment
variables (`EVIDENCE_SOURCE__neon__user`, `EVIDENCE_SOURCE__neon__password`,
base64-encoded, matching `connection.options.yaml`'s format), build command
`npm install --legacy-peer-deps && npm run sources && npm run build`,
publish directory `.evidence/template/build` (confirmed directly from the
installed package's own build script — not the path Evidence's docs examples
often show, so don't second-guess it back to `.evidence/build` or `build/`).

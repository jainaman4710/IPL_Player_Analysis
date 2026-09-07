---
title: RR Pre-Auction Strategy
---

# Rajasthan Royals — Pre-Auction Player Evaluation

Seven independent evaluation axes, no blended score. First draft of the full
dashboard — everything below is live, subject to refinement.

- **[Career-Level Flags](/career-flags)** — Captain / Wicketkeeper / Overseas
  status, playing role, batting/bowling profile.
- **[Batting](/batting)** — raw stats by split (vs pace/spin, home/away,
  phase), batting role, temperament (Anchor/Aggressor).
- **[Bowling](/bowling)** — raw stats by split, engagement bands, Powerplay
  and Death Trust marks.
- **[Fielding](/fielding)** — percentile rank within WK / non-WK peer groups.
- **[SAV](/sav)** — Gaussian-kernel situation-aware value, venue-normalized.
- **[MVP Points](/mvp)** — reconstructed points formula, batting and bowling
  reported separately.
- **[Role Scarcity](/role-scarcity)** — WK-Batsmen, All-rounders,
  Pace-leaning All-rounders, category-level scarcity scores.
- **Aura** — not yet a page; the finalized 10-player list lives in
  `dim_player_aura_flag`, unchanged from before the rebuild.

Everything on this site is generated directly from SQL views in the project's
Neon database (`floral-recipe-26705265`) — no metric here is computed outside
the database.

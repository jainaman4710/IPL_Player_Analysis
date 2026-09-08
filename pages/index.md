---
title: Pre-Auction Player Evaluation
---

# Pre-Auction Player Evaluation

A team-agnostic pre-auction analysis tool — seven independent evaluation
axes, no blended score, built to support auction decision-making generally
rather than being tied to any one franchise.

- **[Batting](/batting)** — genuine combinable filters (season, team, phase,
  opponent bowler type, home/away), plus batting role, MVP, and SAV.
- **[Bowling](/bowling)** — same filtering approach (season, team, phase,
  opponent batting hand, home/away), plus engagement band, trust marks,
  MVP, and SAV.
- **[Fielding](/fielding)** — percentile rank within WK / non-WK peer groups,
  plus a filtered breakdown by season/team/phase/home-away.
- **[SAV](/sav)** — Gaussian-kernel situation-aware value, venue-normalized,
  with Top 5 leaderboards and full methodology detail.
- **[MVP Points](/mvp)** — reconstructed points formula, batting and bowling
  reported separately, with Top 5 leaderboards.
- **[Teams](/teams)** — full roster by team, with career-level flags,
  Role Scarcity, and Aura status shown together here rather than on
  separate pages.

Everything on this site is generated directly from SQL views in the
project's database — no metric here is computed outside the database.

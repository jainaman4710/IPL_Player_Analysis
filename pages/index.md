---
title: Pre-Auction Player Evaluation
---

# Pre-Auction Player Evaluation

This tool exists to support one decision: retain, release, or bid on a
player. Read this page first; each page below is a step in the same
framework, not a standalone report.

## Why there is no blended score

Batting, Bowling, Fielding, SAV, MVP, and Role Scarcity are reported
independently on purpose. Combining them into one number would hide the
trade-offs a decision-maker actually needs to see: a player who is great
at Batting but easily replaceable (low Role Scarcity) is a different call
than one who is mediocre at Batting but plays a scarce role. A single
score would force those two very different situations to look the same.
Every page on this site keeps its numbers separate so you can weigh the
trade-off yourself.

## How to use the pages, in order

1. **Career-Level Flags / Role Scarcity ([Teams](/teams/2025))**: start
   here to see who is even worth discussing. Overseas / Captain / Keeper
   status and Role Scarcity narrow the pool before you look at output.
2. **Batting and Bowling** (MVP and SAV shown inline on both): how good is
   this player, and in what situations. Use the filters (season, team,
   phase, opponent type, home/away) to match the specific matchup or role
   you're evaluating them for.
3. **Fielding**: a tiebreaker, not a primary decision layer. Use it to
   push a genuinely close call ("Grey Zone") toward retain, not to drive
   a decision on its own.

## How to read a page

- **Filters** narrow the table to a specific season, team, phase,
  opponent type, or home/away split; they never change what's being
  measured, only which rows are shown.
- **Clicking a row** on Batting, Bowling, Fielding, SAV, or MVP opens that
  player's profile across all evaluation axes.
- **Top 5 leaderboards** (on SAV and MVP) are unfiltered, whole-pool
  rankings; they're a starting point for who to look at, not a final
  answer.

## Pages

- **[Batting](/batting)**: filter by season, team, phase, opponent bowler
  type, and home/away; includes batting role, MVP points, and SAV.
- **[Bowling](/bowling)**: filter by season, team, phase, opponent batting
  hand, and home/away; includes engagement band, trust marks, MVP points,
  and SAV.
- **[Fielding](/fielding)**: percentile rank within wicketkeeper and
  non-wicketkeeper peer groups, with a season/team breakdown.
- **[SAV](/sav)**: situation-aware value, normalized for venue, with
  Top 5 leaderboards and full methodology.
- **[MVP Points](/mvp)**: points formula for batting and bowling, reported
  separately, with Top 5 leaderboards.
- **Teams**: full rosters with career-level flags and Role Scarcity, by
  season: [2025](/teams/2025) · [2026](/teams/2026)
- **[Compare Players](/compare)**: pick two or three players and see all
  seven axes side by side, for a direct "keep X or take a swing at Y"
  question.

Everything on this site is generated directly from SQL views in the
project's database; no metric here is computed outside the database.

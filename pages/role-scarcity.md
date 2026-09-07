---
title: Role Scarcity
---

# Role Scarcity

Three categories with intentional overlap — a player can qualify for more
than one and gets a separate score in each. Category-level scoring only:
**one shared score per category**, not per player within it. Score =
percentile rank (of population size, inverted so *fewer* players in a
category means *more* scarce) × 10.

**Category definitions** — WK-Batsmen is a direct read of the metadata
`playing_role`. All-rounders and Pace-leaning All-rounders combine the
scouting `playing_role` label with actual observed bowling engagement
(excluding Part-timer/Rarely-Bowls bands) — this combination is a judgment
call, not explicit in the spec, made to avoid crediting someone as an
all-rounder purely on an old scouting tag if they've barely bowled a ball
in 2025–2026.

```sql scarcity_data
select * from neon.role_scarcity
```

```sql category_summary
select * from neon.role_scarcity_category_summary
```

## Category scores

<DataTable data={category_summary} rows=3>
  <Column id=category />
  <Column id=player_count title="Players in Category" />
  <Column id=scarcity_score title="Scarcity Score (0-10)" />
</DataTable>

## Players by category

<DataTable data={scarcity_data} search=true rows=15>
  <Column id=player_name title="Player" />
  <Column id=is_wk_batsman title="WK-Batsman" contentType=colorscale />
  <Column id=is_allrounder title="All-rounder" contentType=colorscale />
  <Column id=is_pace_leaning_allrounder title="Pace-leaning AR" contentType=colorscale />
</DataTable>

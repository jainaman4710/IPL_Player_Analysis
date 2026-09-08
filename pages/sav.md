---
title: SAV
---

# Situation-Aware Value (SAV)

## What it measures

A flat "runs scored" or "runs conceded" number treats every ball as
equivalent. It isn't. A boundary in over 19 with 2 wickets in hand is a far
more valuable contribution than the same boundary in over 3 with 9 wickets
in hand — the first happens under real pressure with few resources left,
the second happens when the batting side can afford to take it. SAV credits
players for outperforming the **specific situation** they were actually in,
not the raw event.

## The baseline: Gaussian-kernel-weighted expected runs

Every legal delivery in the 2025–2026 dataset is placed into a grid cell
defined by **(over number, wickets in hand)** — 20 overs × up to 10 wickets
in hand = up to 200 cells (163 actually occur in the real data; some
combinations, like over 20 with all 10 wickets still in hand, essentially
never happen in T20 cricket).

For each cell, instead of just averaging the runs scored in *that exact*
cell (which would be noisy — some cells have very few observations), the
baseline is a **weighted average across all cells**, where nearby cells
count more and distant cells count less. "Nearby" is measured independently
in each dimension:

- Over-distance uses a bandwidth of **2.5 overs** — a cell 2.5 overs away
  carries meaningfully less weight than an adjacent over.
- Wickets-distance uses a bandwidth of **1.5 wickets** — the baseline
  changes fast as wickets fall, so this dimension is tighter.

The weight formula is a standard Gaussian kernel:
`weight = exp(-0.5 × (distance / bandwidth)²)`, applied separately to the
over-distance and wickets-distance, then multiplied together. Each cell's
contribution is also weighted by how many real deliveries it has, so a
well-observed cell influences its neighbors more than a rarely-seen one.

The result: a smooth, realistic expectation for "how many runs should this
ball go for" at any point in a match — confirmed sensible against the real
data (expected runs rise through the innings, and rise faster in the last
few overs specifically when wickets are still in hand, matching how T20
batting actually accelerates at the death).

## Per-ball credit: asymmetric weighting

Every ball's actual outcome (runs off the bat, plus byes/leg-byes) is
compared to its cell's baseline:

`raw delta = actual runs on this ball − baseline runs for this situation`

If the delta is **positive** (outperformed the situation), it counts at
full weight (1.0×). If **negative** (underperformed), it's dampened to
**0.25× weight**. This is a deliberate design choice from the original
methodology: one bad over shouldn't erase several good ones, so
below-baseline moments are counted but muted, not ignored.

**Bowling SAV is the mirror image** of the same per-ball delta — a bowler
is credited when the batter underperforms their situational baseline, using
the same asymmetric rule from the bowler's perspective (bowler's good
moments count fully, bad moments are dampened).

## Venue normalization

High-scoring grounds inflate raw numbers; low-scoring grounds suppress them.
Each venue's actual average runs-per-ball (across 2025–2026) is compared to
the league-wide average, producing a per-venue multiplier applied to every
credit earned at that ground — so a knock at a genuinely tough batting
venue isn't undervalued relative to the same knock at a batting-friendly one.

## What this page does *not* yet do

Two open questions from the original spec are intentionally not implemented:
whether boom-or-bust scoring (one big over, several quiet ones) should be
weighted differently from steady scoring at the same total, and whether a
momentum/partnership multiplier belongs in the model. This page is the core
mechanism only — flag if either of these should be built out.

```sql sav_data
select * from neon.sav_filterable
```

```sql seasons
select distinct season from ${sav_data} order by season
```

```sql teams
select distinct team from ${sav_data} order by team
```

```sql phases
select distinct phase from ${sav_data} order by phase
```

```sql home_away_options
select distinct home_away from ${sav_data} order by home_away
```

<Dropdown data={seasons} name=season_filter value=season multiple=true selectAllByDefault=true title="Season" />
<Dropdown data={teams} name=team_filter value=team multiple=true selectAllByDefault=true title="Team" />
<Dropdown data={phases} name=phase_filter value=phase multiple=true selectAllByDefault=true title="Phase" />
<Dropdown data={home_away_options} name=home_away_filter value=home_away multiple=true selectAllByDefault=true title="Home / Away" />

```sql filtered_sav
select
    player_id, player_name,
    round(sum(batting_sav), 2) as batting_sav,
    round(sum(bowling_sav), 2) as bowling_sav,
    round(sum(batting_sav) + sum(bowling_sav), 2) as total_sav
from ${sav_data}
where season in ${inputs.season_filter.value}
  and team in ${inputs.team_filter.value}
  and phase in ${inputs.phase_filter.value}
  and home_away in ${inputs.home_away_filter.value}
group by player_id, player_name
```

```sql top5_batting
select player_id, player_name, round(sum(batting_sav), 2) as batting_sav
from ${sav_data}
where season in ${inputs.season_filter.value}
  and team in ${inputs.team_filter.value}
  and phase in ${inputs.phase_filter.value}
  and home_away in ${inputs.home_away_filter.value}
group by player_id, player_name
order by batting_sav desc limit 5
```

```sql top5_bowling
select player_id, player_name, round(sum(bowling_sav), 2) as bowling_sav
from ${sav_data}
where season in ${inputs.season_filter.value}
  and team in ${inputs.team_filter.value}
  and phase in ${inputs.phase_filter.value}
  and home_away in ${inputs.home_away_filter.value}
group by player_id, player_name
order by bowling_sav desc limit 5
```

```sql top5_total
select player_id, player_name, round(sum(batting_sav) + sum(bowling_sav), 2) as total_sav
from ${sav_data}
where season in ${inputs.season_filter.value}
  and team in ${inputs.team_filter.value}
  and phase in ${inputs.phase_filter.value}
  and home_away in ${inputs.home_away_filter.value}
group by player_id, player_name
order by total_sav desc limit 5
```

## Top 5 (within current filter)

<Grid cols=3>
<div>

**Batting**
<DataTable data={top5_batting} downloadable=false>
  <Column id=player_name title="Player" />
  <Column id=batting_sav title="SAV" />
</DataTable>
</div>
<div>

**Bowling**
<DataTable data={top5_bowling} downloadable=false>
  <Column id=player_name title="Player" />
  <Column id=bowling_sav title="SAV" />
</DataTable>
</div>
<div>

**Total**
<DataTable data={top5_total} downloadable=false>
  <Column id=player_name title="Player" />
  <Column id=total_sav title="SAV" />
</DataTable>
</div>
</Grid>

## All players

Click any column header to sort.

<DataTable data={filtered_sav} search=true rows=20 downloadable=false>
  <Column id=player_name title="Player" />
  <Column id=batting_sav title="Batting SAV" />
  <Column id=bowling_sav title="Bowling SAV" />
  <Column id=total_sav title="Total SAV" />
</DataTable>

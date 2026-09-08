---
title: MVP Points
---

# MVP Points

A documented reconstruction of the real IPL points system (the actual formula
is proprietary/unpublished — this is a deliberate, explicit choice, not a
claim of ground truth). Singles, twos, and threes earn **zero** points —
only the events below contribute.

| Event | Points | Credited to |
|---|---|---|
| Four | 2.5 | Batter |
| Six | 3.5 | Batter |
| Wicket (bowler-credited) | 3.5 | Bowler |
| Dot ball | 1.0 | Bowler |
| Catch / stumping | 2.5 | Fielder (full credit, in addition to bowler's 3.5) |
| Run-out | 2.5 | Fielder only (not the 3.5 wicket rate; no bowler credit) |

Batting MVP and Bowling MVP are reported separately, never blended into one
axis-level score — "Total" below is a simple sum of the two for convenience
(MVP is itself a single points system, so summing its own subcomponents
doesn't conflict with the project's no-blended-score rule across *categories*
like Batting/Bowling/SAV).

```sql mvp_data
select * from neon.mvp_filterable
```

```sql seasons
select distinct season from ${mvp_data} order by season
```

```sql teams
select distinct team from ${mvp_data} order by team
```

```sql phases
select distinct phase from ${mvp_data} order by phase
```

```sql home_away_options
select distinct home_away from ${mvp_data} order by home_away
```

<Dropdown data={seasons} name=season_filter value=season multiple=true selectAllByDefault=true title="Season" />
<Dropdown data={teams} name=team_filter value=team multiple=true selectAllByDefault=true title="Team" />
<Dropdown data={phases} name=phase_filter value=phase multiple=true selectAllByDefault=true title="Phase" />
<Dropdown data={home_away_options} name=home_away_filter value=home_away multiple=true selectAllByDefault=true title="Home / Away" />

```sql filtered_mvp
select
    player_id, player_name,
    round(sum(batting_mvp), 2) as batting_mvp,
    round(sum(bowling_mvp), 2) as bowling_mvp,
    round(sum(batting_mvp) + sum(bowling_mvp), 2) as total_mvp
from ${mvp_data}
where season in ${inputs.season_filter.value}
  and team in ${inputs.team_filter.value}
  and phase in ${inputs.phase_filter.value}
  and home_away in ${inputs.home_away_filter.value}
group by player_id, player_name
```

```sql top5_batting
select player_id, player_name, round(sum(batting_mvp), 2) as batting_mvp
from ${mvp_data}
where season in ${inputs.season_filter.value}
  and team in ${inputs.team_filter.value}
  and phase in ${inputs.phase_filter.value}
  and home_away in ${inputs.home_away_filter.value}
group by player_id, player_name
order by batting_mvp desc limit 5
```

```sql top5_bowling
select player_id, player_name, round(sum(bowling_mvp), 2) as bowling_mvp
from ${mvp_data}
where season in ${inputs.season_filter.value}
  and team in ${inputs.team_filter.value}
  and phase in ${inputs.phase_filter.value}
  and home_away in ${inputs.home_away_filter.value}
group by player_id, player_name
order by bowling_mvp desc limit 5
```

```sql top5_total
select player_id, player_name, round(sum(batting_mvp) + sum(bowling_mvp), 2) as total_mvp
from ${mvp_data}
where season in ${inputs.season_filter.value}
  and team in ${inputs.team_filter.value}
  and phase in ${inputs.phase_filter.value}
  and home_away in ${inputs.home_away_filter.value}
group by player_id, player_name
order by total_mvp desc limit 5
```

## Top 5 (within current filter)

<Grid cols=3>
<div>

**Batting**
<DataTable data={top5_batting} downloadable=false>
  <Column id=player_name title="Player" />
  <Column id=batting_mvp title="MVP" />
</DataTable>
</div>
<div>

**Bowling**
<DataTable data={top5_bowling} downloadable=false>
  <Column id=player_name title="Player" />
  <Column id=bowling_mvp title="MVP" />
</DataTable>
</div>
<div>

**Total**
<DataTable data={top5_total} downloadable=false>
  <Column id=player_name title="Player" />
  <Column id=total_mvp title="MVP" />
</DataTable>
</div>
</Grid>

## All players

Click any column header to sort.

<DataTable data={filtered_mvp} search=true rows=20 downloadable=false>
  <Column id=player_name title="Player" />
  <Column id=batting_mvp title="Batting MVP" />
  <Column id=bowling_mvp title="Bowling MVP" />
  <Column id=total_mvp title="Total MVP" />
</DataTable>

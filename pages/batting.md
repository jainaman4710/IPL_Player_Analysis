---
title: Batting
---

# Batting

```sql batting_data
select * from neon.batting_fact_grain
```

## What stands out (2026, no filters applied)

These are fixed to the current season regardless of the filters below;
their job is to give you something to notice before you start filtering,
not to duplicate the table.

```sql top_death_scorer
select player_name, sum(runs) as total_runs
from ${batting_data}
where season = 2026 and phase = 'death'
group by player_name
order by total_runs desc
limit 1
```

```sql home_away_split
with per_player as (
    select player_name,
        sum(case when home_away = 'Home' then runs else 0 end) as home_runs,
        sum(case when home_away = 'Home' then balls_faced else 0 end) as home_balls,
        sum(case when home_away = 'Away' then runs else 0 end) as away_runs,
        sum(case when home_away = 'Away' then balls_faced else 0 end) as away_balls
    from ${batting_data}
    where season = 2026
    group by player_name
)
select player_name,
    round(home_runs * 100.0 / nullif(home_balls, 0), 1) as home_sr,
    round(away_runs * 100.0 / nullif(away_balls, 0), 1) as away_sr
from per_player
where home_balls >= 30 and away_balls >= 30
order by (home_runs * 100.0 / home_balls) - (away_runs * 100.0 / away_balls) desc
limit 1
```

- **Top Death-overs scorer:** {top_death_scorer[0].player_name} ({top_death_scorer[0].total_runs} runs)
- **Biggest home/away swing** (min. 30 balls each venue type): {home_away_split[0].player_name}, strike rate {home_away_split[0].home_sr} at home vs {home_away_split[0].away_sr} away

## Filters

```sql seasons
select distinct season from ${batting_data} order by season
```

```sql teams
select distinct team from ${batting_data} order by team
```

```sql phases
select distinct phase from ${batting_data} order by phase
```

```sql bowler_types
select distinct vs_bowler_type from ${batting_data} order by vs_bowler_type
```

```sql home_away_options
select distinct home_away from ${batting_data} order by home_away
```

<Dropdown data={seasons} name=season_filter value=season multiple=true selectAllByDefault=true title="Season" />
<Dropdown data={teams} name=team_filter value=team multiple=true selectAllByDefault=true title="Team" />
<Dropdown data={phases} name=phase_filter value=phase multiple=true selectAllByDefault=true title="Phase" />
<Dropdown data={bowler_types} name=bowler_type_filter value=vs_bowler_type multiple=true selectAllByDefault=true title="vs Bowler Type" />
<Dropdown data={home_away_options} name=home_away_filter value=home_away multiple=true selectAllByDefault=true title="Home / Away" />

```sql filtered_batting
select
    player_id,
    player_name,
    max(batting_role) as batting_role,
    sum(balls_faced) as balls_faced,
    sum(runs) as total_runs,
    sum(dismissals) as dismissals,
    round(sum(runs) * 100.0 / nullif(sum(balls_faced), 0), 2) as strike_rate,
    case when sum(dismissals) = 0 then null
         else round(sum(runs) * 1.0 / sum(dismissals), 2)
    end as average,
    round(sum(batting_mvp_points), 2) as batting_mvp,
    round(sum(batting_sav), 2) as batting_sav
from ${batting_data}
where season in ${inputs.season_filter.value}
  and team in ${inputs.team_filter.value}
  and phase in ${inputs.phase_filter.value}
  and vs_bowler_type in ${inputs.bowler_type_filter.value}
  and home_away in ${inputs.home_away_filter.value}
group by player_id, player_name
having sum(balls_faced) > 0
order by total_runs desc
```

## Results

Click any column header to sort.

<DataTable data={filtered_batting} search=true rows=20 downloadable=false>
  <Column id=player_name title="Player" />
  <Column id=batting_role title="Role" />
  <Column id=balls_faced title="Balls" />
  <Column id=total_runs title="Runs" />
  <Column id=strike_rate title="SR" />
  <Column id=average title="Avg" />
  <Column id=dismissals />
  <Column id=batting_mvp title="Batting MVP" />
  <Column id=batting_sav title="Batting SAV" />
</DataTable>

## About this page

Filter any combination (season, team, phase, opponent bowler type, home/away)
and the table above recomputes live, e.g. 2025 + vs Spin + Death. MVP and SAV
points (batting component) are shown here too; each also has its own
dedicated page with full detail and Top 5 leaderboards.

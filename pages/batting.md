---
title: Batting
---

# Batting

Filter any combination (season, team, phase, opponent bowler type, home/away)
and the table recomputes live, e.g. 2025 + vs Spin + Death. MVP and SAV
points (batting component) are shown here too; each also has its own
dedicated page with full detail and Top 5 leaderboards.

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

```sql most_improved
with trend as (
    select player_name,
        sum(case when season = 2025 then runs else 0 end) as runs_2025,
        sum(case when season = 2025 then balls_faced else 0 end) as balls_2025,
        sum(case when season = 2026 then runs else 0 end) as runs_2026,
        sum(case when season = 2026 then balls_faced else 0 end) as balls_2026
    from ${batting_data}
    group by player_name
)
select player_name,
    round(runs_2025 * 100.0 / balls_2025, 1) as sr_2025,
    round(runs_2026 * 100.0 / balls_2026, 1) as sr_2026,
    round(((runs_2026 * 100.0 / balls_2026) - (runs_2025 * 100.0 / balls_2025)) / (runs_2025 * 100.0 / balls_2025) * 100, 1) as pct_change
from trend
where balls_2025 >= 60 and balls_2026 >= 60 and runs_2025 > 0
order by pct_change desc
limit 1
```

- **Top Death-overs scorer:** {top_death_scorer[0].player_name} ({top_death_scorer[0].total_runs} runs), minimum sample: none applied, small totals are possible
- **Biggest home/away swing** (min. 30 balls each venue type): {home_away_split[0].player_name}, strike rate {home_away_split[0].home_sr} at home vs {home_away_split[0].away_sr} away
- **Most improved, 2025 to 2026** (min. 60 balls each season): {most_improved[0].player_name}, strike rate {most_improved[0].sr_2025} to {most_improved[0].sr_2026} (+{most_improved[0].pct_change}%)

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
with base as (
    select *
    from ${batting_data}
    where team in ${inputs.team_filter.value}
      and phase in ${inputs.phase_filter.value}
      and vs_bowler_type in ${inputs.bowler_type_filter.value}
      and home_away in ${inputs.home_away_filter.value}
),
selected as (
    select * from base
    where season in ${inputs.season_filter.value}
),
agg as (
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
    from selected
    group by player_id, player_name
    having sum(balls_faced) > 0
),
-- Season trend ignores the Season dropdown on purpose: it always compares
-- 2025 vs 2026 under whatever team/phase/opponent/home-away filters are
-- selected, since the whole point is to see the trend regardless of which
-- single season (or both) the main table is currently showing.
trend as (
    select
        player_id,
        sum(case when season = 2025 then runs else 0 end) as runs_2025,
        sum(case when season = 2025 then balls_faced else 0 end) as balls_2025,
        sum(case when season = 2026 then runs else 0 end) as runs_2026,
        sum(case when season = 2026 then balls_faced else 0 end) as balls_2026
    from base
    group by player_id
)
select
    agg.*,
    case
        when trend.balls_2025 = 0 and trend.balls_2026 > 0 then 'New'
        when trend.balls_2025 > 0 and trend.balls_2026 = 0 then 'No 2026 data'
        when trend.balls_2025 > 0 and trend.balls_2026 > 0 and trend.runs_2025 > 0 then
            round(
                ((trend.runs_2026 * 100.0 / trend.balls_2026) - (trend.runs_2025 * 100.0 / trend.balls_2025))
                / (trend.runs_2025 * 100.0 / trend.balls_2025) * 100,
                1
            )::varchar || '%'
        else null
    end as sr_trend
from agg
left join trend on trend.player_id = agg.player_id
order by total_runs desc
```

## Results

Click any column header to sort. SR Trend compares strike rate across the
two full seasons (regardless of the Season filter above), under whatever
team/phase/opponent/home-away filters are selected. "New" means no 2025
data (rookie, no track record yet); "No 2026 data" means the reverse
(played in 2025, not in 2026 under the current filters). A blank cell
means the player has balls faced in both seasons but a 0 strike rate in
2025, so a percent change isn't meaningful.

<DataTable data={filtered_batting} search=true rows=20 downloadable=false>
  <Column id=player_name title="Player" />
  <Column id=batting_role title="Role" />
  <Column id=balls_faced title="Balls" />
  <Column id=total_runs title="Runs" />
  <Column id=strike_rate title="SR" />
  <Column id=sr_trend title="SR Trend (2025 vs 2026)" />
  <Column id=average title="Avg" />
  <Column id=dismissals />
  <Column id=batting_mvp title="Batting MVP" />
  <Column id=batting_sav title="Batting SAV" />
</DataTable>

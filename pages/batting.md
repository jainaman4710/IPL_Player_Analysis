---
title: Batting
---

# Batting

Filter any combination — season, team, phase, opponent bowler type, home/away
— and the table below recomputes live. All filters default to "everything
selected"; narrow any of them to slice the data, e.g. 2025 + vs Spin + Death.

```sql batting_data
select * from neon.batting_filterable
```

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
    max(temperament) as temperament,
    count(*) as balls_faced,
    sum(runs_batter) as total_runs,
    sum(case when is_dismissal then 1 else 0 end) as dismissals,
    round(sum(runs_batter) * 100.0 / count(*), 2) as strike_rate,
    case when sum(case when is_dismissal then 1 else 0 end) = 0 then null
         else round(sum(runs_batter) * 1.0 / sum(case when is_dismissal then 1 else 0 end), 2)
    end as average
from ${batting_data}
where season in ${inputs.season_filter.value}
  and team in ${inputs.team_filter.value}
  and phase in ${inputs.phase_filter.value}
  and vs_bowler_type in ${inputs.bowler_type_filter.value}
  and home_away in ${inputs.home_away_filter.value}
group by player_id, player_name
having count(*) > 0
order by total_runs desc
```

## Results

<DataTable data={filtered_batting} search=true rows=20>
  <Column id=player_name title="Player" />
  <Column id=batting_role title="Role" />
  <Column id=temperament />
  <Column id=balls_faced title="Balls" />
  <Column id=total_runs title="Runs" />
  <Column id=strike_rate title="SR" />
  <Column id=average title="Avg" />
  <Column id=dismissals />
</DataTable>

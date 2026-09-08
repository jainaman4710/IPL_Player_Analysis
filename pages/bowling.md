---
title: Bowling
---

# Bowling

Filter any combination — season, team, phase, opponent batting hand,
home/away — and the table recomputes live. All filters default to
"everything selected". This is the page your example maps to directly:
2025 + vs LHB + Death.

```sql bowling_data
select * from neon.bowling_filterable
```

```sql seasons
select distinct season from ${bowling_data} order by season
```

```sql teams
select distinct team from ${bowling_data} order by team
```

```sql phases
select distinct phase from ${bowling_data} order by phase
```

```sql batting_hands
select distinct vs_batting_hand from ${bowling_data} order by vs_batting_hand
```

```sql home_away_options
select distinct home_away from ${bowling_data} order by home_away
```

<Dropdown data={seasons} name=season_filter value=season multiple=true selectAllByDefault=true title="Season" />
<Dropdown data={teams} name=team_filter value=team multiple=true selectAllByDefault=true title="Team" />
<Dropdown data={phases} name=phase_filter value=phase multiple=true selectAllByDefault=true title="Phase" />
<Dropdown data={batting_hands} name=hand_filter value=vs_batting_hand multiple=true selectAllByDefault=true title="vs Batting Hand" />
<Dropdown data={home_away_options} name=home_away_filter value=home_away multiple=true selectAllByDefault=true title="Home / Away" />

```sql filtered_bowling
select
    player_id,
    player_name,
    max(engagement_band) as engagement_band,
    bool_or(has_powerplay_trust) as has_powerplay_trust,
    bool_or(has_death_trust) as has_death_trust,
    count(*) filter (where is_legal_ball) as legal_balls,
    sum(runs_conceded) as runs_conceded,
    sum(case when is_bowler_wicket then 1 else 0 end) as wickets,
    round(sum(runs_conceded) * 6.0 / nullif(count(*) filter (where is_legal_ball), 0), 2) as economy,
    round(count(*) filter (where is_legal_ball) * 1.0 / nullif(sum(case when is_bowler_wicket then 1 else 0 end), 0), 2) as strike_rate,
    round(sum(runs_conceded) * 1.0 / nullif(sum(case when is_bowler_wicket then 1 else 0 end), 0), 2) as average
from ${bowling_data}
where season in ${inputs.season_filter.value}
  and team in ${inputs.team_filter.value}
  and phase in ${inputs.phase_filter.value}
  and vs_batting_hand in ${inputs.hand_filter.value}
  and home_away in ${inputs.home_away_filter.value}
group by player_id, player_name
having count(*) filter (where is_legal_ball) > 0
order by wickets desc, economy asc
```

## Results

<DataTable data={filtered_bowling} search=true rows=20>
  <Column id=player_name title="Player" />
  <Column id=engagement_band title="Engagement" />
  <Column id=has_powerplay_trust title="PP Trust" contentType=colorscale />
  <Column id=has_death_trust title="Death Trust" contentType=colorscale />
  <Column id=legal_balls title="Balls" />
  <Column id=runs_conceded title="Runs" />
  <Column id=wickets />
  <Column id=economy />
  <Column id=strike_rate title="SR" />
  <Column id=average title="Avg" />
</DataTable>

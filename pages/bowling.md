---
title: Bowling
---

# Bowling

```sql bowling_data
select * from neon.bowling_fact_grain
```

```sql bowler_type
select * from neon.bowler_type
```

## What stands out (2026, no filters applied)

These are fixed to the current season regardless of the filters below;
their job is to give you something to notice before you start filtering,
not to duplicate the table.

```sql best_pace_economy
select bd.player_name,
    round(sum(bd.runs_conceded) * 6.0 / nullif(sum(bd.legal_balls), 0), 2) as economy,
    sum(bd.legal_balls) as legal_balls
from ${bowling_data} bd
join ${bowler_type} bt on bt.player_id = bd.player_id
where bd.season = 2026 and bt.bowler_type = 'Pace'
group by bd.player_name
having sum(bd.legal_balls) >= 60
order by economy asc
limit 1
```

```sql best_spin_economy
select bd.player_name,
    round(sum(bd.runs_conceded) * 6.0 / nullif(sum(bd.legal_balls), 0), 2) as economy,
    sum(bd.legal_balls) as legal_balls
from ${bowling_data} bd
join ${bowler_type} bt on bt.player_id = bd.player_id
where bd.season = 2026 and bt.bowler_type = 'Spin'
group by bd.player_name
having sum(bd.legal_balls) >= 60
order by economy asc
limit 1
```

```sql top_pp_wickets
select player_name, sum(wickets) as wkts
from ${bowling_data}
where season = 2026 and phase = 'powerplay'
group by player_name
order by wkts desc
limit 1
```

- **Best economy, Pace** (min. 10 overs): {best_pace_economy[0].player_name} at {best_pace_economy[0].economy}
- **Best economy, Spin** (min. 10 overs): {best_spin_economy[0].player_name} at {best_spin_economy[0].economy}
- **Most Powerplay wickets:** {top_pp_wickets[0].player_name} ({top_pp_wickets[0].wkts})

## Filters

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
    sum(legal_balls) as legal_balls,
    sum(runs_conceded) as runs_conceded,
    sum(wickets) as wickets,
    round(sum(runs_conceded) * 6.0 / nullif(sum(legal_balls), 0), 2) as economy,
    round(sum(legal_balls) * 1.0 / nullif(sum(wickets), 0), 2) as strike_rate,
    round(sum(runs_conceded) * 1.0 / nullif(sum(wickets), 0), 2) as average,
    round(sum(bowling_mvp_points), 2) as bowling_mvp,
    round(sum(bowling_sav), 2) as bowling_sav
from ${bowling_data}
where season in ${inputs.season_filter.value}
  and team in ${inputs.team_filter.value}
  and phase in ${inputs.phase_filter.value}
  and vs_batting_hand in ${inputs.hand_filter.value}
  and home_away in ${inputs.home_away_filter.value}
group by player_id, player_name
having sum(legal_balls) > 0
order by wickets desc, economy asc
```

## Results

Click any column header to sort.

<DataTable data={filtered_bowling} search=true rows=20 downloadable=false>
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
  <Column id=bowling_mvp title="Bowling MVP" />
  <Column id=bowling_sav title="Bowling SAV" />
</DataTable>

## About this page

Filter any combination (season, team, phase, opponent batting hand,
home/away) and the table above recomputes live, e.g. 2025 + vs LHB + Death.
MVP and SAV points (bowling component) are shown here too; each also has
its own dedicated page with full detail and Top 5 leaderboards.

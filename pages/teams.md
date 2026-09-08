---
title: Teams
---

# Teams

Full roster by team and season, with career-level flags, Role Scarcity
category membership/scores, and Aura status folded in here rather than
living on separate pages.

```sql roster_data
select * from neon.team_roster
```

```sql teams
select distinct team from ${roster_data} order by team
```

```sql seasons
select distinct season from ${roster_data} order by season
```

<Dropdown data={teams} name=team_filter value=team multiple=true selectAllByDefault=true title="Team" />
<Dropdown data={seasons} name=season_filter value=season multiple=true selectAllByDefault=true title="Season" />

```sql filtered_roster
select *
from ${roster_data}
where team in ${inputs.team_filter.value}
  and season in ${inputs.season_filter.value}
order by team, season, player_name
```

## Roster

<DataTable data={filtered_roster} search=true groupBy="team" rows=25>
  <Column id=player_name title="Player" />
  <Column id=season />
  <Column id=playing_role title="Role" />
  <Column id=is_overseas title="Overseas" contentType=colorscale />
  <Column id=is_captain title="Captain" contentType=colorscale />
  <Column id=is_wicketkeeper title="Keeper" contentType=colorscale />
  <Column id=is_aura_player title="Aura" contentType=colorscale />
  <Column id=is_wk_batsman title="WK-Batsman" contentType=colorscale />
  <Column id=wk_batsman_scarcity_score title="WK Scarcity" />
  <Column id=is_allrounder title="All-rounder" contentType=colorscale />
  <Column id=allrounder_scarcity_score title="AR Scarcity" />
  <Column id=is_pace_leaning_allrounder title="Pace-leaning AR" contentType=colorscale />
  <Column id=pace_allrounder_scarcity_score title="Pace AR Scarcity" />
  <Column id=salary title="Salary (Cr)" />
  <Column id=contract_type />
</DataTable>

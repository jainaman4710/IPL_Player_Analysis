---
title: Fielding
---

# Fielding

Not a primary decision-layer metric — used to push a Grey Zone player into
Retain (top 15th percentile of fielding score). Percentile rank is computed
**separately within WK and non-WK peer groups**, since a wicketkeeper has far
more catch/stumping opportunities than an outfielder — a league-wide
percentile would fill the top 15% almost entirely with keepers.

Fielding score = MVP-formula fielding points (2.5 per catch, stumping, or
run-out), reusing the MVP fielding component rather than inventing a second
fielding metric. Percentile rank below is whole-career (not filter-sliceable,
since it needs the full population to mean anything); the filtered table
further down lets you break the same events down by season/team/phase/home-away.

```sql fielding_data
select * from neon.fielding_evaluation
```

```sql grey_zone_counts
select
    count(*) filter (where peer_group = 'WK' and fielding_percentile >= 85) as wk_top_15,
    count(*) filter (where peer_group = 'non-WK' and fielding_percentile >= 85) as non_wk_top_15
from ${fielding_data}
```

<Grid cols=2>
  <BigValue data={grey_zone_counts} value=wk_top_15 title="WKs in top 15th percentile" />
  <BigValue data={grey_zone_counts} value=non_wk_top_15 title="Non-WKs in top 15th percentile" />
</Grid>

## Whole-career percentile ranking

<DataTable data={fielding_data} search=true groupBy="peer_group" rows=15 downloadable=false>
  <Column id=player_name title="Player" />
  <Column id=catches />
  <Column id=stumpings />
  <Column id=run_outs />
  <Column id=fielding_score title="Fielding Score" />
  <Column id=fielding_percentile title="Percentile (within peer group)" contentType=colorscale />
</DataTable>

## Filtered breakdown

```sql fielding_grain
select * from neon.fielding_fact_grain
```

```sql seasons
select distinct season from ${fielding_grain} order by season
```

```sql teams
select distinct team from ${fielding_grain} order by team
```

```sql phases
select distinct phase from ${fielding_grain} order by phase
```

```sql home_away_options
select distinct home_away from ${fielding_grain} order by home_away
```

<Dropdown data={seasons} name=season_filter value=season multiple=true selectAllByDefault=true title="Season" />
<Dropdown data={teams} name=team_filter value=team multiple=true selectAllByDefault=true title="Team" />
<Dropdown data={phases} name=phase_filter value=phase multiple=true selectAllByDefault=true title="Phase" />
<Dropdown data={home_away_options} name=home_away_filter value=home_away multiple=true selectAllByDefault=true title="Home / Away" />

```sql filtered_fielding
select
    player_id,
    player_name,
    max(playing_role) as role,
    sum(catches) as catches,
    sum(stumpings) as stumpings,
    sum(run_outs) as run_outs,
    sum(fielding_score) as fielding_score
from ${fielding_grain}
where season in ${inputs.season_filter.value}
  and team in ${inputs.team_filter.value}
  and phase in ${inputs.phase_filter.value}
  and home_away in ${inputs.home_away_filter.value}
group by player_id, player_name
having sum(catches) + sum(stumpings) + sum(run_outs) > 0
order by fielding_score desc
```

Click any column header to sort.

<DataTable data={filtered_fielding} search=true rows=20 downloadable=false>
  <Column id=player_name title="Player" />
  <Column id=role title="Role" />
  <Column id=catches />
  <Column id=stumpings />
  <Column id=run_outs />
  <Column id=fielding_score title="Fielding Score" />
</DataTable>

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
fielding metric.

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

## All players

<DataTable data={fielding_data} search=true groupBy="peer_group" rows=15>
  <Column id=player_name title="Player" />
  <Column id=catches />
  <Column id=stumpings />
  <Column id=run_outs />
  <Column id=fielding_score title="Fielding Score" />
  <Column id=fielding_percentile title="Percentile (within peer group)" contentType=colorscale />
</DataTable>

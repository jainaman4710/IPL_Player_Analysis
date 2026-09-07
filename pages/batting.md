---
title: Batting
---

# Batting

Raw season-specific stats with dashboard filters — no sample-size floor, no
composite score. Splits (vs Pace, vs Spin, Home, Away, Powerplay, Middle,
Death) are pre-computed as separate rows rather than a dynamic filter — use
search or group-by to slice.

**Batting role** (Top Order / Middle Order / Finisher / Tail) is derived
from each player's *median actual batting position* across all innings
played, not from the scouting `playing_role` label — bucketed as
positions 1–3 / 4–6 / 7–8 / 9–11. This is a judgment call, not a spec-given
boundary — flag if you want different cutoffs.

**Temperament** (Anchor / Aggressor): a strict median split of Overall
strike rate *within each batting role* — above the role's median is
Aggressor, at or below is Anchor. Peer group is the derived batting role
above, not the metadata `playing_role`.

```sql batting_data
select * from neon.batting_evaluation
```

```sql temperament_data
select * from neon.batting_temperament
```

## Temperament (Anchor / Aggressor)

<DataTable data={temperament_data} search=true groupBy="batting_role" rows=15>
  <Column id=player_name title="Player" />
  <Column id=batting_role title="Role" />
  <Column id=strike_rate title="Overall SR" />
  <Column id=median_sr title="Role Median SR" />
  <Column id=temperament />
</DataTable>

## All players, all splits

<DataTable data={batting_data} search=true groupBy="split_type" rows=15>
  <Column id=player_name title="Player" />
  <Column id=batting_role title="Role" />
  <Column id=balls_faced />
  <Column id=total_runs title="Runs" />
  <Column id=strike_rate title="SR" />
  <Column id=average title="Avg" />
  <Column id=dismissals />
</DataTable>

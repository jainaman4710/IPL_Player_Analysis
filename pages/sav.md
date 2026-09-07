---
title: SAV
---

# Situation-Aware Value (SAV)

Per-ball performance measured against a **Gaussian-kernel-weighted baseline**
of expected runs for that exact (over, wickets-in-hand) match situation —
not a flat league average. A boundary in over 19 with 2 wickets in hand
means something different than the same boundary in over 3 with 9 wickets
in hand; SAV credits the player for outperforming the *specific* situation,
not the raw event.

**Mechanics** (kernel bandwidths H_over=2.5, H_wickets=1.5, both fixed by
spec): baseline is fit once across all 2025–2026 deliveries, then every
ball's actual runs are compared against its cell's baseline. Contributions
above baseline count at full (1.0×) weight; below-baseline contributions are
dampened to 0.25× — a deliberate asymmetry so one bad over doesn't erase
several good ones. Bowling SAV is the mirror image of the same per-ball
delta (bowler benefits when the batter underperforms).
**Venue-normalized**: high-scoring grounds discount credit, low-scoring
grounds boost it, using each venue's actual average runs-per-ball against
the league average.

**Not yet reflected here, carried forward as open questions from the spec**:
whether boom-or-bust scoring should be weighted differently from steady
scoring at the same total, and whether a momentum/partnership multiplier
belongs in the model. This page implements the core mechanism only.

```sql sav_data
select * from neon.sav_points
```

## All players, by season

<DataTable data={sav_data} search=true groupBy="season" rows=15>
  <Column id=player_name title="Player" />
  <Column id=season />
  <Column id=batting_sav title="Batting SAV" />
  <Column id=bowling_sav title="Bowling SAV" />
</DataTable>

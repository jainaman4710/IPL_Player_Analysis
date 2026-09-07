---
title: MVP Points
---

# MVP Points

A documented reconstruction of the real IPL points system (the actual formula
is proprietary/unpublished — this is a deliberate, explicit choice, not a
claim of ground truth). Singles, twos, and threes earn **zero** points —
only the events below contribute.

| Event | Points | Credited to |
|---|---|---|
| Four | 2.5 | Batter |
| Six | 3.5 | Batter |
| Wicket (bowler-credited) | 3.5 | Bowler |
| Dot ball | 1.0 | Bowler |
| Catch / stumping | 2.5 | Fielder (full credit, in addition to bowler's 3.5) |
| Run-out | 2.5 | Fielder only (not the 3.5 wicket rate; no bowler credit) |

Reported as Batting MVP and Bowling MVP separately, per player per season —
not blended into one number. Not venue-normalized.

```sql mvp_data
select * from neon.mvp_points
```

## All players, by season

Use the table's built-in search to filter by season or player.

<DataTable data={mvp_data} search=true rows=15>
  <Column id=player_name title="Player" />
  <Column id=season />
  <Column id=batting_mvp title="Batting MVP" />
  <Column id=bowling_mvp title="Bowling MVP" />
  <Column id=fielding_mvp_share title="Fielding MVP (shown separately, not summed in)" />
</DataTable>

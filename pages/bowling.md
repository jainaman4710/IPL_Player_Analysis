---
title: Bowling
---

# Bowling

Raw season-specific stats with splits (vs LHB, vs RHB, Home, Away,
Powerplay, Middle, Death), plus engagement classification and trust marks.

**Engagement band** — derived from (matches bowled in / matches played),
thresholds 80/60/40/25% per the old framework. Band *labels* are a judgment
call on my part (the spec carried the four threshold numbers forward but not
what each band should be called) — flag if these don't match the original
intent:
- ≥80%: Primary Bowler · ≥60%: Frontline Bowler · ≥40%: Regular All-rounder
- ≥25%: Part-timer · below 25%: Rarely Bowls

**Trust marks** — Powerplay/Death Trust: bowled a full over (≥6 legal
balls) in that phase in ≥30% of matches played, per spec.

```sql bowling_data
select * from neon.bowling_evaluation
```

## All players, all splits

<DataTable data={bowling_data} search=true groupBy="split_type" rows=15>
  <Column id=player_name title="Player" />
  <Column id=legal_balls title="Balls" />
  <Column id=runs_conceded />
  <Column id=wickets />
  <Column id=economy />
  <Column id=strike_rate title="SR" />
  <Column id=average title="Avg" />
  <Column id=engagement_band title="Engagement" />
  <Column id=has_powerplay_trust title="PP Trust" contentType=colorscale />
  <Column id=has_death_trust title="Death Trust" contentType=colorscale />
</DataTable>

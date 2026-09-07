---
title: Career-Level Flags
---

# Career-Level Flags

Career-level status derived directly from `v_player_career_flags` in Neon —
`is_captain` / `is_wicketkeeper` come from actual per-match leadership records
(`dim_match_leadership`, 149 matches across 2025–2026), not season defaults.

```sql player_flags
select * from neon.player_career_flags
```

```sql summary_counts
select
    count(*) as total_players,
    count(*) filter (where is_captain) as total_captains,
    count(*) filter (where is_wicketkeeper) as total_keepers,
    count(*) filter (where is_overseas) as total_overseas
from ${player_flags}
```

<Grid cols=4>
  <BigValue data={summary_counts} value=total_players title="Contracted Players" />
  <BigValue data={summary_counts} value=total_captains title="Have Captained" />
  <BigValue data={summary_counts} value=total_keepers title="Have Kept Wicket" />
  <BigValue data={summary_counts} value=total_overseas title="Overseas Players" />
</Grid>

## All players

Search, sort, or group by role — every column here is pulled straight from
the view, nothing computed in this page.

<DataTable data={player_flags} search=true groupBy="playing_role" rows=15>
  <Column id=player_name title="Player" />
  <Column id=playing_role title="Role" />
  <Column id=batting_hand title="Batting" />
  <Column id=bowling_style title="Bowling" />
  <Column id=is_overseas title="Overseas" contentType=colorscale />
  <Column id=is_captain title="Captain?" contentType=colorscale />
  <Column id=captain_matches title="Matches Captained" />
  <Column id=is_wicketkeeper title="Keeper?" contentType=colorscale />
  <Column id=keeper_matches title="Matches Kept" />
</DataTable>

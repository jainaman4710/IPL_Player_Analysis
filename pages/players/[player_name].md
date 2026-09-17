---
title: Player Profile
---

# {params.player_name}

```sql roster_info
select team, playing_role, is_overseas, is_captain, is_wicketkeeper,
    is_aura_player, active_2025, active_2026, contract_type_2026, price_2026
from neon.team_roster
where player_name = '${params.player_name}'
order by active_2026 desc
limit 1
```

{#if roster_info.length > 0}
**{roster_info[0].team}** · {roster_info[0].playing_role}
{#if roster_info[0].contract_type_2026}
· {roster_info[0].contract_type_2026} for 2026{#if roster_info[0].price_2026} at ₹{roster_info[0].price_2026} Cr{/if}
{/if}

{#if roster_info[0].is_overseas}Overseas · {/if}{#if roster_info[0].is_captain}Captain · {/if}{#if roster_info[0].is_wicketkeeper}Keeper · {/if}{#if roster_info[0].is_aura_player}Aura · {/if}Active: {#if roster_info[0].active_2025}2025 {/if}{#if roster_info[0].active_2026}2026{/if}
{/if}

Everything below is pulled from the same six axis views used on their own
pages — nothing here is a new metric or a combined score. Follow any link
to see the full page and its filters.

```sql batting_summary
select round(sum(runs), 0) as runs,
    round(sum(runs) * 100.0 / nullif(sum(balls_faced), 0), 2) as sr
from neon.batting_fact_grain
where player_name = '${params.player_name}'
```

```sql bowling_summary
select round(sum(wickets), 0) as wickets,
    round(sum(runs_conceded) * 6.0 / nullif(sum(legal_balls), 0), 2) as economy
from neon.bowling_fact_grain
where player_name = '${params.player_name}'
```

```sql fielding_summary
select fielding_percentile, peer_group
from neon.fielding_evaluation
where player_name = '${params.player_name}'
```

```sql sav_summary
select round(sum(batting_sav), 2) as batting_sav,
    round(sum(bowling_sav), 2) as bowling_sav
from neon.sav_filterable
where player_name = '${params.player_name}'
```

```sql mvp_summary
select round(sum(batting_mvp) + sum(bowling_mvp), 2) as total_mvp
from neon.mvp_filterable
where player_name = '${params.player_name}'
```

## Across the six axes

{#if batting_summary[0].runs}
- **[Batting](/batting)** — {batting_summary[0].runs} runs, SR {batting_summary[0].sr}
{/if}
{#if bowling_summary[0].wickets}
- **[Bowling](/bowling)** — {bowling_summary[0].wickets} wickets, economy {bowling_summary[0].economy}
{/if}
{#if fielding_summary.length > 0}
- **[Fielding](/fielding)** — {fielding_summary[0].fielding_percentile} percentile within {fielding_summary[0].peer_group}
{/if}
- **[SAV](/sav)** — {sav_summary[0].batting_sav} batting SAV, {sav_summary[0].bowling_sav} bowling SAV
- **[MVP Points](/mvp)** — {mvp_summary[0].total_mvp} total MVP
- **[Teams / Roster](/teams)** — full contract and career-flag history

```sql season_breakdown
select season,
    sum(balls_faced) as balls,
    sum(runs) as runs,
    round(sum(runs) * 100.0 / nullif(sum(balls_faced), 0), 2) as sr
from neon.batting_fact_grain
where player_name = '${params.player_name}'
group by season
order by season
```

{#if season_breakdown.length > 0}
## Season breakdown (batting)

<DataTable data={season_breakdown} downloadable=false>
  <Column id=season />
  <Column id=balls />
  <Column id=runs />
  <Column id=sr title="SR" />
</DataTable>
{/if}

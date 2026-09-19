---
title: Compare Players
---

# Compare Players

Pick up to three players to lay their numbers side by side. This is the
same seven independent axes used everywhere else on the site (no blended
score here either): pick the alternatives you're actually weighing against
each other for a retain/release call, and read the trade-off yourself.

Each player's snapshot uses their current team where known (2026 roster if
they're on one, otherwise their 2025 team), and stats are combined across
both seasons (2025 and 2026 together), same as the default view on every
other page.

```sql player_list
select distinct player_name
from neon.team_roster
order by player_name
```

<Dropdown data={player_list} name=player_a value=player_name title="Player A" defaultValue="V Kohli" />
<Dropdown data={player_list} name=player_b value=player_name title="Player B" defaultValue="SV Samson" />
<Dropdown data={player_list} name=player_c value=player_name title="Player C (optional)" defaultValue="JJ Bumrah" />

```sql current_snapshot
select
    player_id, player_name, team,
    is_overseas, role_scarcity, playing_role,
    case when active_2026 then is_captain_2026 else is_captain_2025 end as is_captain,
    case when active_2026 then is_wicketkeeper_2026 else is_wicketkeeper_2025 end as is_wicketkeeper,
    row_number() over (partition by player_id order by active_2026 desc, active_2025 desc) as rn
from neon.team_roster
```

```sql batting_agg
select player_id,
    sum(balls_faced) as balls_faced,
    sum(runs) as total_runs,
    round(sum(runs) * 100.0 / nullif(sum(balls_faced), 0), 2) as strike_rate,
    case when sum(dismissals) = 0 then null
         else round(sum(runs) * 1.0 / sum(dismissals), 2)
    end as average
from neon.batting_fact_grain
group by player_id
```

```sql bowling_agg
select player_id,
    sum(legal_balls) as legal_balls,
    sum(wickets) as wickets,
    round(sum(runs_conceded) * 6.0 / nullif(sum(legal_balls), 0), 2) as economy
from neon.bowling_fact_grain
group by player_id
```

```sql sav_agg
select player_id,
    round(sum(batting_sav), 2) as batting_sav,
    round(sum(bowling_sav), 2) as bowling_sav,
    round(sum(batting_sav) + sum(bowling_sav), 2) as total_sav
from neon.sav_filterable
group by player_id
```

```sql mvp_agg
select player_id,
    round(sum(batting_mvp), 2) as batting_mvp,
    round(sum(bowling_mvp), 2) as bowling_mvp,
    round(sum(batting_mvp) + sum(bowling_mvp), 2) as total_mvp
from neon.mvp_filterable
group by player_id
```

```sql mvp_rank
select player_id, rank() over (order by total_mvp desc) as mvp_rank
from (
    select player_id, sum(batting_mvp) + sum(bowling_mvp) as total_mvp
    from neon.mvp_filterable
    group by player_id
) t
```

```sql fielding_data
select * from neon.fielding_evaluation
```

```sql compare_pool
select
    s.player_name, s.team, s.playing_role, s.is_overseas, s.is_captain, s.is_wicketkeeper,
    s.role_scarcity,
    b.total_runs, b.strike_rate, b.average,
    bw.wickets, bw.economy,
    sv.batting_sav, sv.bowling_sav, sv.total_sav,
    mv.batting_mvp, mv.bowling_mvp, mv.total_mvp, mr.mvp_rank,
    f.fielding_percentile, f.peer_group
from current_snapshot s
left join batting_agg b on b.player_id = s.player_id
left join bowling_agg bw on bw.player_id = s.player_id
left join sav_agg sv on sv.player_id = s.player_id
left join mvp_agg mv on mv.player_id = s.player_id
left join mvp_rank mr on mr.player_id = s.player_id
left join fielding_data f on f.player_id = s.player_id
where s.rn = 1
```

```sql player_a_stats
select * from ${compare_pool} where player_name = '${inputs.player_a.value}'
```

```sql player_b_stats
select * from ${compare_pool} where player_name = '${inputs.player_b.value}'
```

```sql player_c_stats
select * from ${compare_pool} where player_name = '${inputs.player_c.value}'
```

## Side by side

| Metric | {inputs.player_a.value} | {inputs.player_b.value} | {inputs.player_c.value} |
|---|---|---|---|
| Team | {player_a_stats[0]?.team ?? '-'} | {player_b_stats[0]?.team ?? '-'} | {player_c_stats[0]?.team ?? '-'} |
| Role | {player_a_stats[0]?.playing_role ?? '-'} | {player_b_stats[0]?.playing_role ?? '-'} | {player_c_stats[0]?.playing_role ?? '-'} |
| Overseas | {player_a_stats[0]?.is_overseas ? 'Yes' : 'No'} | {player_b_stats[0]?.is_overseas ? 'Yes' : 'No'} | {player_c_stats[0]?.is_overseas ? 'Yes' : 'No'} |
| Additional Flags | {[player_a_stats[0]?.is_captain && 'Captain', player_a_stats[0]?.is_wicketkeeper && 'Keeper'].filter(Boolean).length ? [player_a_stats[0]?.is_captain && 'Captain', player_a_stats[0]?.is_wicketkeeper && 'Keeper'].filter(Boolean).join(', ') : '-'} | {[player_b_stats[0]?.is_captain && 'Captain', player_b_stats[0]?.is_wicketkeeper && 'Keeper'].filter(Boolean).length ? [player_b_stats[0]?.is_captain && 'Captain', player_b_stats[0]?.is_wicketkeeper && 'Keeper'].filter(Boolean).join(', ') : '-'} | {[player_c_stats[0]?.is_captain && 'Captain', player_c_stats[0]?.is_wicketkeeper && 'Keeper'].filter(Boolean).length ? [player_c_stats[0]?.is_captain && 'Captain', player_c_stats[0]?.is_wicketkeeper && 'Keeper'].filter(Boolean).join(', ') : '-'} |
| Role Scarcity | {player_a_stats[0]?.role_scarcity ?? 'NA'} | {player_b_stats[0]?.role_scarcity ?? 'NA'} | {player_c_stats[0]?.role_scarcity ?? 'NA'} |
| Runs (both seasons) | {player_a_stats[0]?.total_runs ?? '-'} | {player_b_stats[0]?.total_runs ?? '-'} | {player_c_stats[0]?.total_runs ?? '-'} |
| Batting SR | {player_a_stats[0]?.strike_rate ?? '-'} | {player_b_stats[0]?.strike_rate ?? '-'} | {player_c_stats[0]?.strike_rate ?? '-'} |
| Batting Avg | {player_a_stats[0]?.average ?? '-'} | {player_b_stats[0]?.average ?? '-'} | {player_c_stats[0]?.average ?? '-'} |
| Wickets (both seasons) | {player_a_stats[0]?.wickets ?? '-'} | {player_b_stats[0]?.wickets ?? '-'} | {player_c_stats[0]?.wickets ?? '-'} |
| Bowling Economy | {player_a_stats[0]?.economy ?? '-'} | {player_b_stats[0]?.economy ?? '-'} | {player_c_stats[0]?.economy ?? '-'} |
| Batting SAV | {player_a_stats[0]?.batting_sav ?? '-'} | {player_b_stats[0]?.batting_sav ?? '-'} | {player_c_stats[0]?.batting_sav ?? '-'} |
| Bowling SAV | {player_a_stats[0]?.bowling_sav ?? '-'} | {player_b_stats[0]?.bowling_sav ?? '-'} | {player_c_stats[0]?.bowling_sav ?? '-'} |
| Total SAV | {player_a_stats[0]?.total_sav ?? '-'} | {player_b_stats[0]?.total_sav ?? '-'} | {player_c_stats[0]?.total_sav ?? '-'} |
| Batting MVP | {player_a_stats[0]?.batting_mvp ?? '-'} | {player_b_stats[0]?.batting_mvp ?? '-'} | {player_c_stats[0]?.batting_mvp ?? '-'} |
| Bowling MVP | {player_a_stats[0]?.bowling_mvp ?? '-'} | {player_b_stats[0]?.bowling_mvp ?? '-'} | {player_c_stats[0]?.bowling_mvp ?? '-'} |
| Total MVP (rank of 222) | {player_a_stats[0]?.total_mvp ?? '-'} (#{player_a_stats[0]?.mvp_rank ?? '-'}) | {player_b_stats[0]?.total_mvp ?? '-'} (#{player_b_stats[0]?.mvp_rank ?? '-'}) | {player_c_stats[0]?.total_mvp ?? '-'} (#{player_c_stats[0]?.mvp_rank ?? '-'}) |
| Fielding Percentile | {player_a_stats[0]?.fielding_percentile ?? '-'} ({player_a_stats[0]?.peer_group ?? '-'}) | {player_b_stats[0]?.fielding_percentile ?? '-'} ({player_b_stats[0]?.peer_group ?? '-'}) | {player_c_stats[0]?.fielding_percentile ?? '-'} ({player_c_stats[0]?.peer_group ?? '-'}) |

Fielding percentile is only comparable within the same peer group (WK vs
non-WK); it's shown here with the peer group it was computed against, not
as a league-wide number. Runs, wickets, SAV, and MVP are pooled across
2025 and 2026 combined; leave the individual axis pages open if you want a
single-season snapshot instead.

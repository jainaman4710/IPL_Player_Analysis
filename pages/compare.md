---
title: Compare Players
---

# Compare Players

Pick two or three players to lay their numbers side by side. This is the
same seven independent axes used everywhere else on the site, no blended
score here either: pick the alternatives you're actually weighing against
each other for a retain/release call, and read the trade-off yourself.

Each player's team, role, and flags reflect their current season snapshot
(2026 roster if they're on one, otherwise 2025). Batting, bowling, SAV,
and MVP numbers respect the Season filter below; team/flags and fielding
percentile are whole-career/current-snapshot regardless of that filter.

```sql player_list
select distinct player_name
from neon.team_roster
order by player_name
```

<Dropdown data={player_list} name=player_a value=player_name title="Player A" defaultValue="V Kohli" />
<Dropdown data={player_list} name=player_b value=player_name title="Player B" defaultValue="SV Samson" />
<Dropdown data={player_list} name=player_c value=player_name title="Player C (optional)" defaultValue="JJ Bumrah" />

```sql seasons
select distinct season from neon.batting_fact_grain order by season
```

<Dropdown data={seasons} name=season_filter value=season multiple=true selectAllByDefault=true title="Season" />

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
where season in ${inputs.season_filter.value}
group by player_id
```

```sql bowling_agg
select player_id,
    sum(legal_balls) as legal_balls,
    sum(wickets) as wickets,
    round(sum(runs_conceded) * 6.0 / nullif(sum(legal_balls), 0), 2) as economy
from neon.bowling_fact_grain
where season in ${inputs.season_filter.value}
group by player_id
```

```sql sav_agg
select player_id,
    round(sum(batting_sav), 2) as batting_sav,
    round(sum(bowling_sav), 2) as bowling_sav,
    round(sum(batting_sav) + sum(bowling_sav), 2) as total_sav
from neon.sav_filterable
where season in ${inputs.season_filter.value}
group by player_id
```

```sql mvp_agg
select player_id,
    round(sum(batting_mvp), 2) as batting_mvp,
    round(sum(bowling_mvp), 2) as bowling_mvp,
    round(sum(batting_mvp) + sum(bowling_mvp), 2) as total_mvp
from neon.mvp_filterable
where season in ${inputs.season_filter.value}
group by player_id
```

```sql mvp_rank
select player_id, rank() over (order by total_mvp desc) as mvp_rank
from (
    select player_id, sum(batting_mvp) + sum(bowling_mvp) as total_mvp
    from neon.mvp_filterable
    where season in ${inputs.season_filter.value}
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
from ${current_snapshot} s
left join ${batting_agg} b on b.player_id = s.player_id
left join ${bowling_agg} bw on bw.player_id = s.player_id
left join ${sav_agg} sv on sv.player_id = s.player_id
left join ${mvp_agg} mv on mv.player_id = s.player_id
left join ${mvp_rank} mr on mr.player_id = s.player_id
left join ${fielding_data} f on f.player_id = s.player_id
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

<table>
<thead>
<tr>
  <th>Metric</th>
  <th>{inputs.player_a.value}</th>
  <th>{inputs.player_b.value}</th>
  <th>{inputs.player_c.value}</th>
</tr>
</thead>
<tbody>
<tr>
  <td>Team</td>
  <td>{player_a_stats[0]?.team ?? '-'}</td>
  <td>{player_b_stats[0]?.team ?? '-'}</td>
  <td>{player_c_stats[0]?.team ?? '-'}</td>
</tr>
<tr>
  <td>Role</td>
  <td>{player_a_stats[0]?.playing_role ?? '-'}</td>
  <td>{player_b_stats[0]?.playing_role ?? '-'}</td>
  <td>{player_c_stats[0]?.playing_role ?? '-'}</td>
</tr>
<tr>
  <td>Overseas</td>
  <td>{player_a_stats[0]?.is_overseas ? 'Yes' : 'No'}</td>
  <td>{player_b_stats[0]?.is_overseas ? 'Yes' : 'No'}</td>
  <td>{player_c_stats[0]?.is_overseas ? 'Yes' : 'No'}</td>
</tr>
<tr>
  <td>Additional Flags</td>
  <td>{[player_a_stats[0]?.is_captain && 'Captain', player_a_stats[0]?.is_wicketkeeper && 'Keeper'].filter(Boolean).length ? [player_a_stats[0]?.is_captain && 'Captain', player_a_stats[0]?.is_wicketkeeper && 'Keeper'].filter(Boolean).join(', ') : '-'}</td>
  <td>{[player_b_stats[0]?.is_captain && 'Captain', player_b_stats[0]?.is_wicketkeeper && 'Keeper'].filter(Boolean).length ? [player_b_stats[0]?.is_captain && 'Captain', player_b_stats[0]?.is_wicketkeeper && 'Keeper'].filter(Boolean).join(', ') : '-'}</td>
  <td>{[player_c_stats[0]?.is_captain && 'Captain', player_c_stats[0]?.is_wicketkeeper && 'Keeper'].filter(Boolean).length ? [player_c_stats[0]?.is_captain && 'Captain', player_c_stats[0]?.is_wicketkeeper && 'Keeper'].filter(Boolean).join(', ') : '-'}</td>
</tr>
<tr>
  <td>Role Scarcity</td>
  <td>{player_a_stats[0]?.role_scarcity ?? 'NA'}</td>
  <td>{player_b_stats[0]?.role_scarcity ?? 'NA'}</td>
  <td>{player_c_stats[0]?.role_scarcity ?? 'NA'}</td>
</tr>
<tr>
  <td colspan="4" style="background-color: rgba(59, 130, 246, 0.15); font-weight: 600;">Batting</td>
</tr>
<tr style="background-color: rgba(59, 130, 246, 0.06);">
  <td>Runs (selected seasons)</td>
  <td>{player_a_stats[0]?.total_runs ?? '-'}</td>
  <td>{player_b_stats[0]?.total_runs ?? '-'}</td>
  <td>{player_c_stats[0]?.total_runs ?? '-'}</td>
</tr>
<tr style="background-color: rgba(59, 130, 246, 0.06);">
  <td>Batting SR</td>
  <td>{player_a_stats[0]?.strike_rate ?? '-'}</td>
  <td>{player_b_stats[0]?.strike_rate ?? '-'}</td>
  <td>{player_c_stats[0]?.strike_rate ?? '-'}</td>
</tr>
<tr style="background-color: rgba(59, 130, 246, 0.06);">
  <td>Batting Avg</td>
  <td>{player_a_stats[0]?.average ?? '-'}</td>
  <td>{player_b_stats[0]?.average ?? '-'}</td>
  <td>{player_c_stats[0]?.average ?? '-'}</td>
</tr>
<tr style="background-color: rgba(59, 130, 246, 0.06);">
  <td>Batting SAV</td>
  <td>{player_a_stats[0]?.batting_sav ?? '-'}</td>
  <td>{player_b_stats[0]?.batting_sav ?? '-'}</td>
  <td>{player_c_stats[0]?.batting_sav ?? '-'}</td>
</tr>
<tr style="background-color: rgba(59, 130, 246, 0.06);">
  <td>Batting MVP</td>
  <td>{player_a_stats[0]?.batting_mvp ?? '-'}</td>
  <td>{player_b_stats[0]?.batting_mvp ?? '-'}</td>
  <td>{player_c_stats[0]?.batting_mvp ?? '-'}</td>
</tr>
<tr>
  <td colspan="4" style="background-color: rgba(249, 115, 22, 0.15); font-weight: 600;">Bowling</td>
</tr>
<tr style="background-color: rgba(249, 115, 22, 0.06);">
  <td>Wickets (selected seasons)</td>
  <td>{player_a_stats[0]?.wickets ?? '-'}</td>
  <td>{player_b_stats[0]?.wickets ?? '-'}</td>
  <td>{player_c_stats[0]?.wickets ?? '-'}</td>
</tr>
<tr style="background-color: rgba(249, 115, 22, 0.06);">
  <td>Bowling Economy</td>
  <td>{player_a_stats[0]?.economy ?? '-'}</td>
  <td>{player_b_stats[0]?.economy ?? '-'}</td>
  <td>{player_c_stats[0]?.economy ?? '-'}</td>
</tr>
<tr style="background-color: rgba(249, 115, 22, 0.06);">
  <td>Bowling SAV</td>
  <td>{player_a_stats[0]?.bowling_sav ?? '-'}</td>
  <td>{player_b_stats[0]?.bowling_sav ?? '-'}</td>
  <td>{player_c_stats[0]?.bowling_sav ?? '-'}</td>
</tr>
<tr style="background-color: rgba(249, 115, 22, 0.06);">
  <td>Bowling MVP</td>
  <td>{player_a_stats[0]?.bowling_mvp ?? '-'}</td>
  <td>{player_b_stats[0]?.bowling_mvp ?? '-'}</td>
  <td>{player_c_stats[0]?.bowling_mvp ?? '-'}</td>
</tr>
<tr>
  <td colspan="4" style="background-color: rgba(115, 115, 115, 0.12); font-weight: 600;">Combined and other</td>
</tr>
<tr>
  <td>Total SAV</td>
  <td>{player_a_stats[0]?.total_sav ?? '-'}</td>
  <td>{player_b_stats[0]?.total_sav ?? '-'}</td>
  <td>{player_c_stats[0]?.total_sav ?? '-'}</td>
</tr>
<tr>
  <td>Total MVP (rank, selected seasons)</td>
  <td>{player_a_stats[0]?.total_mvp ?? '-'} (#{player_a_stats[0]?.mvp_rank ?? '-'})</td>
  <td>{player_b_stats[0]?.total_mvp ?? '-'} (#{player_b_stats[0]?.mvp_rank ?? '-'})</td>
  <td>{player_c_stats[0]?.total_mvp ?? '-'} (#{player_c_stats[0]?.mvp_rank ?? '-'})</td>
</tr>
<tr>
  <td>Fielding Percentile</td>
  <td>{player_a_stats[0]?.fielding_percentile ?? '-'} ({player_a_stats[0]?.peer_group ?? '-'})</td>
  <td>{player_b_stats[0]?.fielding_percentile ?? '-'} ({player_b_stats[0]?.peer_group ?? '-'})</td>
  <td>{player_c_stats[0]?.fielding_percentile ?? '-'} ({player_c_stats[0]?.peer_group ?? '-'})</td>
</tr>
</tbody>
</table>

The Batting and Bowling sections are tinted (blue and orange) to make the
two easy to tell apart at a glance; Team/Role/Flags/Role Scarcity above
them and Total SAV/Total MVP/Fielding Percentile below them are left
neutral since they aren't specific to one discipline. Fielding percentile
is only comparable within the same peer group (WK vs non-WK); it's shown
here with the peer group it was computed against, not as a league-wide
number.

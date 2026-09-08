---
title: Teams
---

# Teams

Full roster by team, with career-level flags (Captain/Keeper/Overseas),
Role Scarcity, and Aura status folded in here rather than living on
separate pages.

**Role Scarcity methodology**: three categories — WK-Batsmen, All-rounders,
and Pace-leaning All-rounders (a subset of All-rounders) — each scored by
how rare that category is in the full 315-player pool, min-max normalized
so the rarest category scores 10, the most common scores 1, and categories
in between are placed proportionally based on their actual player count
(not a fixed midpoint). The table below shows a single **Role Scarcity**
column: the *maximum* score across whichever categories a player actually
qualifies for (not a sum — qualifying for two categories doesn't double a
player's scarcity value), or **NA** if none apply.

**On the 2025/2026 columns below**: a player can be released by one team and
bought by another (or the same team) in a later auction — 27 players in
this dataset changed teams between 2025 and 2026. Each such player appears
as a **separate row under each team** they were actually contracted to,
with the season columns correctly marking only the season(s) they were on
*that specific* team. Contract price is shown only when the contract type
is `auction` or `retained` — `replacement` signings (in-season injury/other
replacements) don't have a comparable public price, so that column is
intentionally blank for them rather than showing a misleading value.

```sql roster_data
select * from neon.team_roster
```

```sql teams
select distinct team from ${roster_data} order by team
```

<Dropdown data={teams} name=team_filter value=team multiple=true selectAllByDefault=true title="Team" />

```sql filtered_roster
select
    team, player_name, playing_role, is_overseas,
    active_2025, active_2026,
    contract_type_2025, contract_type_2026,
    price_2025, price_2026,
    is_captain, is_wicketkeeper, is_aura_player,
    coalesce(role_scarcity::text, 'NA') as role_scarcity
from ${roster_data}
where team in ${inputs.team_filter.value}
order by team, player_name
```

## Roster

Click any column header to sort.

<DataTable data={filtered_roster} search=true rows=25 downloadable=false>
  <Column id=team />
  <Column id=player_name title="Player" />
  <Column id=playing_role title="Role" />
  <Column id=is_overseas title="Overseas" contentType=colorscale />
  <Column id=active_2025 title="2025" contentType=colorscale />
  <Column id=active_2026 title="2026" contentType=colorscale />
  <Column id=contract_type_2025 title="2025 Type" />
  <Column id=contract_type_2026 title="2026 Type" />
  <Column id=price_2025 title="2025 Price (Cr)" />
  <Column id=price_2026 title="2026 Price (Cr)" />
  <Column id=is_captain title="Captain" contentType=colorscale />
  <Column id=is_wicketkeeper title="Keeper" contentType=colorscale />
  <Column id=is_aura_player title="Aura" contentType=colorscale />
  <Column id=role_scarcity title="Role Scarcity" />
</DataTable>

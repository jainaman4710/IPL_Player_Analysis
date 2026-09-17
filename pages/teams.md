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
as a **separate row under each team** they were actually contracted to. The
**Active** column marks only the season(s) they were on *that specific*
team; **Contract 2025** / **Contract 2026** show that season's contract
type and price together, and are blank for a season this row's team-contract
wasn't active. Price is shown only when the contract type is `auction` or
`retained` — `replacement` signings (in-season injury/other replacements)
don't have a comparable public price, so it's intentionally blank for them
rather than showing a misleading value.

```sql roster_data
select * from neon.team_roster
```

```sql teams
select distinct team from ${roster_data} order by team
```

<Dropdown data={teams} name=team_filter value=team multiple=true selectAllByDefault=true title="Team" />

```sql filtered_roster
select
    team,
    player_name,
    playing_role,
    nullif(concat_ws(', ',
        case when is_overseas then 'Overseas' end,
        case when is_captain then 'Captain' end,
        case when is_wicketkeeper then 'Keeper' end,
        case when is_aura_player then 'Aura' end
    ), '') as flags,
    concat_ws(', ',
        case when active_2025 then '2025' end,
        case when active_2026 then '2026' end
    ) as active_seasons,
    case when active_2025 then
        nullif(concat_ws(' · ',
            upper(substr(contract_type_2025, 1, 1)) || substr(contract_type_2025, 2),
            case when price_2025 is not null then '₹' || price_2025 || ' Cr' end
        ), '')
    end as contract_2025,
    case when active_2026 then
        nullif(concat_ws(' · ',
            upper(substr(contract_type_2026, 1, 1)) || substr(contract_type_2026, 2),
            case when price_2026 is not null then '₹' || price_2026 || ' Cr' end
        ), '')
    end as contract_2026,
    coalesce(role_scarcity::text, 'NA') as role_scarcity
from ${roster_data}
where team in ${inputs.team_filter.value}
order by team, player_name
```

## Roster

Click any column header to sort. Flags shows only whichever of
Overseas / Captain / Keeper / Aura actually apply to that player — blank
means none do. This replaces four separate Yes/No columns from the previous
version of this table (same for the two Active-season columns, and folding
each season's contract type + price into one Contract column instead of two).

<DataTable data={filtered_roster} search=true rows=25 downloadable=false>
  <Column id=team />
  <Column id=player_name title="Player" />
  <Column id=playing_role title="Role" />
  <Column id=flags title="Flags" />
  <Column id=active_seasons title="Active" />
  <Column id=contract_2025 title="Contract 2025" />
  <Column id=contract_2026 title="Contract 2026" />
  <Column id=role_scarcity title="Role Scarcity" />
</DataTable>

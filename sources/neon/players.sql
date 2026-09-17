-- One row per player, used by pages/players/[player_name].md to generate
-- one static page per player at build time (Evidence's Templated Pages
-- feature). Column name must match the parameter name in the template
-- filename: player_name.
select distinct player_name
from neon.team_roster
order by player_name

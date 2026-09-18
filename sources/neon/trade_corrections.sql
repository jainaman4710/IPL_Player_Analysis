-- Real 2026 IPL trades currently mislabeled in dim_contracts.
-- Verified against public reporting (punjabkesari.com IPL 2026 retention/
-- trade list, africa.espn.com, cricket.com), cross-checked one by one
-- against the exact salaries already in the database. All 9 below match
-- their public salary exactly.
--
-- RUN ON A DISPOSABLE BRANCH FIRST, then review, then apply to main.
-- This does NOT need a new contract_type value added anywhere in code:
-- the display logic already does upper(substr(contract_type,1,1)) ||
-- substr(contract_type,2), so 'trade' will render as "Trade" automatically
-- once the value is corrected here.

update dim_contracts c
set contract_type = 'trade'
from dim_player p
where c.player_id = p.player_id
  and c.season = 2026
  and c.contract_type in ('retained', 'replacement')
  and p.player_name in (
      'Arjun Tendulkar', 'D Ferreira', 'M Markande', 'Mohammed Shami',
      'N Rana', 'RA Jadeja', 'SE Rutherford', 'SM Curran', 'SV Samson'
  );

-- Shardul Thakur (SN Thakur) is a 10th confirmed trade (LSG to MI, INR 2 Cr,
-- the IPL's first officially announced trade ahead of 2026) but he is
-- MISSING his entire 2025 contract row in dim_contracts, not just
-- mislabeled, so he needs an insert, not an update. Public reporting:
-- signed by LSG from the Registered Available Player Pool as an injury
-- replacement for Mohsin Khan, at his reserve price of INR 2 Cr.
insert into dim_contracts (player_id, season, franchise, contract_type, salary)
select player_id, 2025, 'LSG', 'replacement', 2
from dim_player
where player_name = 'SN Thakur';

update dim_contracts c
set contract_type = 'trade'
from dim_player p
where c.player_id = p.player_id
  and c.season = 2026
  and p.player_name = 'SN Thakur';

-- NOT included: MD Shanaka (GT to RR, tagged 'replacement'). No public
-- trade record found for him; his team change under 'replacement' may be
-- a genuine in-season replacement signing rather than a mislabeled trade.
-- Flagging for your own confirmation rather than guessing.

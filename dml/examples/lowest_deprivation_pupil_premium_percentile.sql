select
	os.local_authority,
	percentile_disc(0.4) within group (order by dpp.allocation) as "P40", -- discrete percentile at 0.4 (40%)
	percentile_disc(0.5) within group (order by dpp.allocation) as "P50",
	percentile_disc(0.6) within group (order by dpp.allocation) as "P60",
	percentile_disc(0.7) within group (order by dpp.allocation) as "P70",
	percentile_disc(0.8) within group (order by dpp.allocation) as "P80",
	percentile_disc(0.9) within group (order by dpp.allocation) as "P90"
from
	deprivation_pupil_premium dpp
inner join
	open_schools os
		on dpp.urn = os.urn
group by
	os.local_authority
having
	count(*) > 15                                                         -- only select local authorities with more than fifteen schools
order by
	avg(dpp.allocation::decimal) asc                                      -- order by DPP allocation ascending, we want the lowest
limit
	20
;

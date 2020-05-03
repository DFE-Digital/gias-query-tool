select
	os.urn,
	os.name
from
	open_schools os
where st_dwithin(
	os.coordinates,                         -- Database column that holds the school's location
	st_setsrid(
		st_makepoint(-1.826194, 51.178868), -- Stonehenge's coords
		4326                                -- World Geodetic System
	),
	3000                                    -- Search radius in metres
);

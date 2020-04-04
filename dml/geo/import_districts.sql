insert into local_authorities (
	name,
	edge
)
select
	lad13nm as name,
	st_geomfromewkb(wkb_geometry) as edge
from
	local_authority_districts_raw
;

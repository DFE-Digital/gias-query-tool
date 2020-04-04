insert into regions (
	name,
	edge
)
select
	eer13nm as name,
	st_geomfromewkb(wkb_geometry) as edge
from
	electoral_regions_raw
;

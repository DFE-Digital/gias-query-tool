with local_authorities_to_exclude as (
	select
		st_union(edge) as edges                               -- union multiple edges into a single geometry
	from
		local_authorities
	where
		name in (
			'Kensington and Chelsea',
			'Southwark',
			'Tower Hamlets'
		)
)
select
	distinct on (urn)
	os.urn,
	os.name,
	os.coordinates
from
	open_schools os
inner join                                                    -- join on region containing coordinates
	regions r
		on st_contains(
			r.edge,
			os.coordinates::geometry
		)
inner join                                                    -- exclude the named LAs from above
	local_authorities la
		on not st_contains(
			(select edges from local_authorities_to_exclude),
			os.coordinates::geometry
		)
where
	r.name = 'London'
;

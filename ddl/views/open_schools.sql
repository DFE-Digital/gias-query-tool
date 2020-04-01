drop materialized view if exists open_schools;

create materialized view open_schools as (
	select *
	from schools
	where open
);

create index if not exists index_open_schools_urn on open_schools(urn);
create index if not exists index_open_schools_name on open_schools(name);
create index if not exists index_open_schools_coordinates on open_schools using gist(coordinates);

refresh materialized view open_schools;

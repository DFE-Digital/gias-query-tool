drop materialized view if exists open_schools;

create materialized view open_schools as (
	select
		*
	from
		schools
	where
		open
);

create index if not exists index_open_schools_urn on open_schools(urn);
create index if not exists index_open_schools_urn on open_schools(ukprn);
create index if not exists index_open_schools_name on open_schools(name);
create index if not exists index_open_schools_phase on open_schools(phase);
create index if not exists index_open_schools_establishment on open_schools(establishment_type);
create index if not exists index_open_schools_establishment_group on open_schools(establishment_type_group);
create index if not exists index_open_schools_opened_on on open_schools(opened_on);
create index if not exists index_open_schools_censused_on on open_schools(censused_on);
create index if not exists index_open_schools_coordinates on open_schools using gist(coordinates);

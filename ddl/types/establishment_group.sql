drop type if exists establishment_group;

create type establishment_group as enum (
	'Academies',
	'Colleges',
	'Free Schools',
	'Independent schools',
	'Local authority maintained schools',
	'Other types',
	'Special schools',
	'Universities',
	'Welsh schools'
);

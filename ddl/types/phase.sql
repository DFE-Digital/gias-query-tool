drop type if exists phase;

create type phase as enum (
	'16 plus',
	'All-through',
	'Middle deemed primary',
	'Middle deemed secondary',
	'Not applicable',
	'Nursery',
	'Primary',
	'Secondary'
);

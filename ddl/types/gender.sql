drop type if exists gender;

create type gender as enum (
	'Boys',
	'Girls',
	'Mixed',
	'Not applicable'
);

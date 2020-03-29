drop type if exists ofsted_rating;

create type ofsted_rating as enum (
	'Outstanding',
	'Good',
	'Requires improvement',
	'Serious Weaknesses',
	'Inadequate',
	'Special Measures'
);

drop type if exists ofsted_rating;

create type ofsted_rating as enum (
	'Requires improvement',
	'Serious Weaknesses',
	'Outstanding',
	'Good',
	'Special Measures',
	'Inadequate'
);

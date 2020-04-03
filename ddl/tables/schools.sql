create extension if not exists postgis;

drop table if exists schools;

create table schools (
	urn integer primary key,
	name varchar(120) not null,
	local_authority varchar(40) not null,
	establishment_type establishment not null,
	establishment_type_group establishment_group not null,
	open boolean not null,
	opened_on date null,
	closed_on date null,
	censused_on date null,
	pupils integer,
	boys integer,
	girls integer,
	gender gender,
	coordinates geography(point),
	ofsted_rating ofsted_rating,
	phase phase,
	free_school_meals_percentage numeric,
	start_age integer,
	finish_age integer,
	capacity integer,
	rural_urban_classification rural_urban_classification
);

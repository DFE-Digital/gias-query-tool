drop table if exists deprivation_pupil_premium;

create table deprivation_pupil_premium (
	urn integer primary key references schools,

	primary_pupils integer,
	primary_pupils_eligible integer,
	primary_pupils_eligible_percentage decimal,
	primary_allocation money,

	secondary_pupils integer,
	secondary_pupils_eligible integer,
	secondary_pupils_eligible_percentage decimal,
	secondary_allocation money,

	pupils_eligible integer,
	allocation money
);

drop table if exists school_links;

create table school_links (
	urn1 integer references schools(urn),
	urn2 integer references schools(urn),
	type link_type,
	date date
);

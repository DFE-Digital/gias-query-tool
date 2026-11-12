drop type if exists link_type;

create type link_type as enum (
	'Closure',
	'Expansion',
	'Merged - change in age range',
	'Merged - expansion in school capacity and changer in age range',
	'Merged - expansion of school capacity',
	'Other',
	'Predecessor',
	'Predecessor - Split School',
	'Predecessor - amalgamated',
	'Predecessor - merged',
	'Result of Amalgamation',
	'Sixth Form Centre Link',
	'Sixth Form Centre School',
	'Successor',
	'Successor - Split School',
	'Successor - amalgamated',
	'Successor - merged'
)

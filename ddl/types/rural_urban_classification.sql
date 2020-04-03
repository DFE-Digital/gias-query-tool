drop type if exists rural_urban_classification;

create type rural_urban_classification as enum (
	-- https://www.gov.uk/government/collections/rural-urban-classification
	'Rural village in a sparse setting',
	'Urban major conurbation',
	'Urban city and town',
	'Rural town and fringe',
	'Rural hamlet and isolated dwellings',
	'Rural town and fringe in a sparse setting',
	'Urban minor conurbation',
	'Rural village',
	'Urban city and town in a sparse setting',
	'Rural hamlet and isolated dwellings in a sparse setting',

	-- ¯\_(ツ)_/¯
	'Postcode in NI/Channel Is/IoM (pseudo)',

	-- https://www2.gov.scot/Topics/Statistics/About/Methodology/UrbanRuralClassification
	'Large urban area (Scotland)',
	'Remote rural (Scotland)',
	'Accessible rural (Scotland)',
	'Remote small town (Scotland)',
	'Other urban area (Scotland)'
);

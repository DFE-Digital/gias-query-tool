drop type if exists rural_urban_classification;

/*
 * the classifications are now all upper case because the Scottish exist in
 * multiple combinations of capitalisation, eg 'Large Urban Area', 'Large Urban
 * area' and 'Large urban area'
 */
create type rural_urban_classification as enum (
	-- https://www.gov.uk/government/collections/rural-urban-classification
	'RURAL VILLAGE IN A SPARSE SETTING',
	'URBAN MAJOR CONURBATION',
	'URBAN CITY AND TOWN',
	'RURAL TOWN AND FRINGE',
	'RURAL HAMLET AND ISOLATED DWELLINGS',
	'RURAL TOWN AND FRINGE IN A SPARSE SETTING',
	'URBAN MINOR CONURBATION',
	'RURAL VILLAGE',
	'URBAN CITY AND TOWN IN A SPARSE SETTING',
	'RURAL HAMLET AND ISOLATED DWELLINGS IN A SPARSE SETTING',

	-- ¯\_(ツ)_/¯
	'POSTCODE IN NI/CHANNEL IS/IOM (PSEUDO)',
	'(PSEUDO) CHANNEL ISLANDS/ISLE OF MAN',

	-- https://www2.gov.scot/Topics/Statistics/About/Methodology/UrbanRuralClassification
	'ACCESSIBLE RURAL',
	'LARGE URBAN AREA',
	'OTHER URBAN AREA',
	'REMOTE RURAL',
	'REMOTE SMALL TOWN'
);

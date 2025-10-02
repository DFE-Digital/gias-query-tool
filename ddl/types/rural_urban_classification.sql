drop type if exists rural_urban_classification;

/*
 * the classifications are now all upper case because the Scottish exist in
 * multiple combinations of capitalisation, eg 'Large Urban Area', 'Large Urban
 * area' and 'Large urban area'
 */
create type rural_urban_classification as enum (
	-- https://www.gov.uk/government/collections/rural-urban-classification
	'LARGER RURAL: FURTHER FROM A MAJOR TOWN OR CITY',
	'LARGER RURAL: NEARER TO A MAJOR TOWN OR CITY',
	'RURAL HAMLET AND ISOLATED DWELLINGS IN A SPARSE SETTING',
	'RURAL HAMLET AND ISOLATED DWELLINGS',
	'RURAL TOWN AND FRINGE IN A SPARSE SETTING',
	'RURAL TOWN AND FRINGE',
	'RURAL VILLAGE IN A SPARSE SETTING',
	'RURAL VILLAGE',
	'SMALLER RURAL: FURTHER FROM A MAJOR TOWN OR CITY',
	'SMALLER RURAL: NEARER TO A MAJOR TOWN OR CITY',
	'URBAN CITY AND TOWN IN A SPARSE SETTING',
	'URBAN CITY AND TOWN',
	'URBAN MAJOR CONURBATION',
	'URBAN MINOR CONURBATION',
	'URBAN: FURTHER FROM A MAJOR TOWN OR CITY',
	'URBAN: NEARER TO A MAJOR TOWN OR CITY',

	-- ¯\_(ツ)_/¯
	'POSTCODE IN NI/CHANNEL IS/IOM (PSEUDO)',
	'(PSEUDO) CHANNEL ISLANDS/ISLE OF MAN',

	-- https://www2.gov.scot/Topics/Statistics/About/Methodology/UrbanRuralClassification
	'ACCESSIBLE RURAL',
	'ACCESSIBLE SMALL TOWN',
	'LARGE URBAN AREA',
	'OTHER URBAN AREA',
	'REMOTE RURAL',
	'REMOTE SMALL TOWN',
	'VERY REMOTE SMALL TOWN'
);

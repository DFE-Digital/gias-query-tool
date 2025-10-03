drop type if exists rural_urban_classification;

/*
 * the classifications are now all upper case because the Scottish exist in
 * multiple combinations of capitalisation, eg 'Large Urban Area', 'Large Urban
 * area' and 'Large urban area'
 */
create type rural_urban_classification as enum (
	-- England/Wales
	'RURAL HAMLET AND ISOLATED DWELLINGS IN A SPARSE SETTING',
	'RURAL HAMLET AND ISOLATED DWELLINGS',
	'RURAL TOWN AND FRINGE IN A SPARSE SETTING',
	'RURAL TOWN AND FRINGE',
	'RURAL VILLAGE IN A SPARSE SETTING',
	'RURAL VILLAGE',
	'URBAN CITY AND TOWN IN A SPARSE SETTING',
	'URBAN CITY AND TOWN',
	'URBAN MAJOR CONURBATION',
	'URBAN MINOR CONURBATION',

	-- Scotland
	'ACCESSIBLE RURAL',
	'ACCESSIBLE SMALL RURAL',
	'ACCESSIBLE SMALL TOWN',
	'LARGE URBAN AREA',
	'OTHER URBAN AREA',
	'REMOTE RURAL',
	'REMOTE SMALL TOWN',
	'VERY REMOTE SMALL TOWN',

	-- Urban (unspecified)
	'URBAN: NEARER TO A MAJOR TOWN OR CITY',
	'URBAN: FURTHER FROM A MAJOR TOWN OR CITY',

	-- Rural (unspecified)
	'LARGER RURAL: FURTHER FROM A MAJOR TOWN OR CITY',
	'LARGER RURAL: NEARER TO A MAJOR TOWN OR CITY',
	'SMALLER RURAL: FURTHER FROM A MAJOR TOWN OR CITY',
	'SMALLER RURAL: NEARER TO A MAJOR TOWN OR CITY',

	-- Pseudo (Channel Islands/Isle of Man)
	'CHANNEL ISLANDS/ISLE OF MAN'
);

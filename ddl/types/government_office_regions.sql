drop type if exists government_office_region;

/*
 * UK Government Office Regions
 * https://wicid.ukdataservice.ac.uk/cider/info.php?geogtype=29
 *
 * 1,North East,A
 * 2,North West,B
 * 3,Yorkshire and The Humber,D
 * 4,East Midlands,E
 * 5,West Midlands,F
 * 6,East of England,G
 * 7,London,H
 * 8,South East,J
 * 9,South West,K
 * 10,Wales,W
 * 11,Scotland,S
 * 12,Northern Ireland,N
 */

create type government_office_region as enum (
	'North East',
	'North West',
	'Yorkshire and The Humber',
	'East Midlands',
	'West Midlands',
	'East of England',
	'London',
	'South East',
	'South West',
	'Wales',
	'Scotland',
	'Northern Ireland'
);

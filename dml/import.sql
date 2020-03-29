insert into schools (
	urn,
	name,
	establishment_type,
	establishment_type_group,
	open,
	opened_on,
	closed_on,
	censused_on,
	pupils,
	boys,
	girls,
	gender,
	coordinates,
	ofsted_rating,
	phase
)

select
	sr."URN"::integer,
	sr."EstablishmentName",
	sr."TypeOfEstablishment (name)"::establishment,
	sr."EstablishmentTypeGroup (name)"::establishment_group,

	case -- open
	when (sr."EstablishmentStatus (name)" = 'Open' or sr."EstablishmentStatus (name)" = 'Open, but proposed to close')
		then true
	else -- "Proposed to open" or "Closed"
		false
	end,

	case -- opened_on
	when (sr."OpenDate" is null or sr."OpenDate" = '')
		then null
	else
		sr."OpenDate"::date
	end,

	case -- closed_on
	when (sr."CloseDate" is null or sr."CloseDate" = '')
		then null
	else
		sr."CloseDate"::date
	end,

	case -- censused_on
	when (sr."CensusDate" is null or sr."CensusDate" = '')
		then null
	else
		sr."CensusDate"::date
	end,

	nullif(sr."NumberOfPupils", '')::integer,
	nullif(sr."NumberOfBoys", '')::integer,
	nullif(sr."NumberOfGirls", '')::integer,
	nullif(sr."Gender (name)", '')::gender,

	case -- coordinates
	when (sr."Easting" = '' or sr."Northing" = '')
		then null
	else
		/*
		 * convert to WGS84 (EPSG:4326), the *standard* coordinate system that's
		 * used in GPS and online mapping tools
		 *
		 * https://en.wikipedia.org/wiki/World_Geodetic_System
		 */
		st_transform(
			/*
			 * transform the raw point to a British National Grid (EPSG:27700) one,
			 * this is the format used by The Ordinance Survey
			 *
			 * https://en.wikipedia.org/wiki/Ordnance_Survey_National_Grid
			 */
			st_setsrid(
				/*
				 * return a point with an unknown SRID using the raw easting/northing
				 * values
				 *
				 * https://en.wikipedia.org/wiki/Easting_and_northing
				 */
				st_makepoint(
					sr."Easting"::integer,
					sr."Northing"::integer
				),
				27700
			),
			4326
		)
	end,

	nullif(sr."OfstedRating (name)", '')::ofsted_rating,
	nullif(sr."PhaseOfEducation (name)", '')::phase

from
	schools_raw sr;

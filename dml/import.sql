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
	girls
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
	nullif(sr."NumberOfGirls", '')::integer

from
	schools_raw sr;

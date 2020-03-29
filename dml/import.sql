insert into schools (
	urn,
	name,
	establishment_type,
	establishment_type_group,
	open
)

select
	sr."URN"::integer,
	sr."EstablishmentName",
	sr."TypeOfEstablishment (name)"::establishment,
	sr."EstablishmentTypeGroup (name)"::establishment_group,

	case
	when (sr."EstablishmentStatus (name)" = 'Open' or sr."EstablishmentStatus (name)" = 'Open, but proposed to close')
		then true
	else -- "Proposed to open" or "Closed"
		false
	end

from
	schools_raw sr;

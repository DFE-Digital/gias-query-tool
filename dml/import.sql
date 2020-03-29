insert into schools (
	urn,
	name,
	establishment_type
)

select
	sr."URN"::integer,
	sr."EstablishmentName",
	sr."TypeOfEstablishment (name)"::establishment

from
	schools_raw sr;

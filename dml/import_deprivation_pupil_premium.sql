insert into deprivation_pupil_premium (
	urn,

	primary_pupils,
	primary_pupils_eligible,
	primary_pupils_eligible_percentage,
	primary_allocation,

	secondary_pupils,
	secondary_pupils_eligible,
	secondary_pupils_eligible_percentage,
	secondary_allocation,

	pupils_eligible,
	allocation
)

select
	"URN",

	"Primary pupils on roll",
	"Primary pupils eligible for DPP",
	"Primary pupils eligible for DPP Percentage",
	"Primary DPP Allocation",

	"Secondary pupils on roll",
	"Secondary pupils eligible for DPP",
	"Secondary pupils eligible for DPP Percentage",
	"Secondary DPP Allocation",

	"Total number of pupils eligible for DPP",
	"Total allocation for DPP"

from
	deprivation_pupil_premium_raw;

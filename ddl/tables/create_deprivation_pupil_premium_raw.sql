drop table if exists deprivation_pupil_premium_raw;

/*
 * Deprivation Pupil Premium (DPP) data
 *
 * https://www.gov.uk/government/publications/pupil-premium-allocations-and-conditions-of-grant-2019-to-2020
 */

create table deprivation_pupil_premium_raw (
	"URN" integer not null,
	"LAEstab" decimal not null,
	"LA" decimal not null,
	"Local Authority" varchar not null,
	"Estab" decimal not null,
	"School Name" varchar not null,
	"School Type" varchar not null,
	"Parliamentary Constituency" varchar not null,
	"Pupils on roll" decimal not null,
	"Primary pupils on roll" decimal not null,
	"Primary pupils eligible for DPP" decimal not null,
	"Primary pupils eligible for DPP Percentage" decimal not null,
	"Primary DPP Allocation" decimal not null,
	"Secondary pupils on roll" decimal not null,
	"Secondary pupils eligible for DPP" decimal not null,
	"Secondary pupils eligible for DPP Percentage" decimal not null,
	"Secondary DPP Allocation" decimal not null,
	"Total number of pupils eligible for DPP" decimal not null,
	"Total allocation for DPP" decimal not null
);

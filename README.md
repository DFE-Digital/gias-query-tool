# The [Unofficial] GIAS Query Toolkit

Ever wanted quickly query the [Get Information About
Schools](https://get-information-schools.service.gov.uk/) dataset but couldn't
because it's provided in an unwieldy CSV file that's not properly-encoded and
has too many columns?

Great, you're in the right place!

This set of tools downloads and imports the data into a locally-running PostgreSQL
database and lets you take advantage of [PostGIS](https://postgis.net/) to supercharge
your queries.

## Example queries

### "What's the breakdown of school genders by Ofsted rating?" 😕

```sql
select
  ofsted_rating as "Ofsted rating",
  gender,
  count(*)
from
  open_schools
group by
  ofsted_rating,
  gender
order by
  ofsted_rating,
  gender
\crosstabview

┌──────────────────────┬──────┬───────┬───────┬────────┬────────────────┐
│    Ofsted rating     │ Boys │ Girls │ Mixed │ (null) │ Not applicable │
╞══════════════════════╪══════╪═══════╪═══════╪════════╪════════════════╡
│ Outstanding          │   58 │    95 │  3343 │      1 │                │
│ Good                 │  139 │   107 │ 13844 │      1 │                │
│ Requires improvement │   37 │    19 │  2017 │        │                │
│ Inadequate           │   20 │    13 │    70 │        │                │
│ Serious Weaknesses   │    2 │     1 │    97 │        │                │
│ Special Measures     │    7 │     1 │   165 │        │                │
│ (null)               │  166 │   225 │  4886 │    256 │           1345 │
└──────────────────────┴──────┴───────┴───────┴────────┴────────────────┘
```

### "Find all the schools within 3km of [Stonehenge](https://en.wikipedia.org/wiki/Stonehenge)" 🤔

```sql
select
  urn,
  name
from
  open_schools
where st_dwithin(
  coordinates,                            -- Database column that holds the school's location
  st_setsrid(
    st_makepoint(-1.826194, 51.178868),   -- Stonehenge's coords
    4326                                  -- World Geodetic System
  ),
  3000                                    -- Search radius in metres
);


┌────────┬───────────────────────────────────────────────┐
│  urn   │                     name                      │
╞════════╪═══════════════════════════════════════════════╡
│ 145545 │ Larkhill Primary School                       │
│ 143006 │ St Michael's Church of England Primary School │
└────────┴───────────────────────────────────────────────┘
```

Obligatory sense check 🧐

![larkhill_primary](docs/images/larkhill_primary.png)

Looks good!

### "Which 10 local authorities have the highest capacity secondary schools?" 🤨

```sql
with highest_capacity_schools as (
	select
		distinct on(local_authority) -- one school per LA

		local_authority,
		name as school_name,
		capacity
	from
		open_schools
	where
		phase = 'Secondary'
	and
		capacity is not null
	order by
		local_authority,
		capacity desc
)
select
	local_authority,
	school_name,
	capacity
from
	highest_capacity_schools
order by
	capacity desc
limit 10;

┌─────────────────────────┬─────────────────────────────────┬──────────┐
│     local_authority     │           school_name           │ capacity │
╞═════════════════════════╪═════════════════════════════════╪══════════╡
│ Nottinghamshire         │ Ashfield Comprehensive School   │     3146 │
│ Devon                   │ Exmouth Community College       │     2850 │
│ Redbridge               │ Beal High School                │     2840 │
│ Milton Keynes           │ Stantonbury International       │     2669 │
│ West Sussex             │ Steyning Grammar School         │     2455 │
│ Kent                    │ Oasis Academy Isle of Sheppey   │     2450 │
│ Croydon                 │ Harris Academy South Norwood    │     2450 │
│ Dorset                  │ The Thomas Hardye School        │     2392 │
│ North East Lincolnshire │ Tollbar Academy                 │     2355 │
│ Brighton and Hove       │ Cardinal Newman Catholic School │     2262 │
└─────────────────────────┴─────────────────────────────────┴──────────┘
```

## Getting up and running

### Prerequisites

* [**Ruby**](https://www.ruby-lang.org/en/), only used for scrubbing and correcting line endings in the GIAS CSV
* [**GNU Make**](https://www.gnu.org/software/make/), used to run the automatic download and import
* [**PostgreSQL**](https://www.postgresql.org/) with an local superuser account
* [**PostGIS**](https://postgis.net/) for geographic query goodness

### Running the command

```bash
make
```

## Manual importing

### 1. Download

```bash
wget https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata20200328.csv
```

### 2. Cleanse

```bash
scripts/cleanse < edubasealldata20200328.csv > edubasealldata20200328-cleansed.csv
```

### 3. Fix line endings

```bash
scripts/fix-line-endings < edubasealldata20200328.csv > edubasealldata20200328-cleansed.csv
```

### 4. Generate create table statement using csvsql

```bash
csvsql -v -i postgresql edubasealldata20200328-cleansed.csv > out.sql
```
	
### 5. Create a new empty database

```bash
createdb gias
```

### 6. Create database objects

Use the scripts in the `ddl` directory to create the required objects for the
database, use the `Makefile` for guidance

### 8. Copy raw data

```bash
psql gias --command "\copy schools_raw from 'edubasealldata20200328-cleansed-fixed.csv' with csv header"
```

### 9. Import

```bash
psql < dml/import.sql
```

## FAQs

### Why use [enums](https://www.postgresql.org/docs/12/datatype-enum.html) when you could've just used a `varchar`?

Efficiency aside, the main reason is to allow [ordering by _rank_ rather than
alphabetic position](https://www.postgresql.org/docs/12/datatype-enum.html#id-1.5.7.15.6).

## Nomenclature

| Word                                                         | Definition                                                                                                                                                     |
| --------------                                               | ----------                                                                                                                                                     |
| EduBase                                                      | The old name for [Get information about schools](https://get-information-schools.service.gov.uk/) (GIAS)                                                       |
| [Ofsted](https://www.gov.uk/government/organisations/ofsted) | The Office for Standards in Education, Children's Services and Skills (Ofsted) is a non-ministerial department of the UK government, reporting to Parliament.A |
| [URN](https://en.wikipedia.org/wiki/Unique_Reference_Number) | A six-digit number used by the UK government to identify educational establishments in the United Kingdom.                                                     |

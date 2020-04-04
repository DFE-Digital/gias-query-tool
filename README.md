# The [Unofficial] GIAS Query Toolkit

Ever wanted quickly query the [Get Information About
Schools](https://get-information-schools.service.gov.uk/) dataset but couldn't
because it's provided in an unwieldy CSV file that's not properly-encoded and
has too many columns?

Great, you're in the right place!

This set of tools downloads and imports the data into a locally-running PostgreSQL
database and lets you take advantage of [PostGIS](https://postgis.net/) to supercharge
your queries.

## Getting up and running

### Prerequisites

* [**Ruby**](https://www.ruby-lang.org/en/), only used for scrubbing and correcting line endings in the GIAS CSV
* [**GNU Make**](https://www.gnu.org/software/make/), used to run the automatic download and import
* [**PostgreSQL**](https://www.postgresql.org/) with an local superuser account
* [**PostGIS**](https://postgis.net/) for geographic query goodness

### Running the command

To download, cleanse, import and build the data objects only a single command
should be required.

```bash
$ make
```

When debugging, use `make refresh` to run the import steps without repeatedly downloading
the export file.

```bash
$ make refresh
```

## Manual importing

The entire import, apart from file cleansing, is written in standard SQL. Executing
the statements needs to be done in the correct order, the `Makefile` is the best
place to get a feel for how it works.

## Tables and views

The importer creates the following database objects:

| Name                         | Type                | Description                                                        |
| ----                         | ----                | -----------                                                        |
| `schools`                    | `table`             | All schools, both open and closed                                  |
| `open_schools`               | `materialized view` | Only open schools                                                  |
| `regions`                    | `table`             | England's regions and associated gegoraphic information            |
| `local_authorities`          | `table`             | England's local authorities and associated gegoraphic information  |
| `establishment`              | `type`              | School types (eg. Foundation school, Free school)                  |
| `establishment_group`        | `type`              | School categories (eg. Independent Schools, Universities, Colleges |
| `gender`                     | `type`              | School gender policies (eg. Boys, Girls, Mixed)                    |
| `ofsted_rating`              | `type`              | All Ofsted ratings, including deprecated ones                      |
| `phase`                      | `type`              | School phases (eg. Secondary, Primary, 16 plus)                    |
| `rural_urban_classification` | `type`              | Classification of a school's setting, source links in definition   |


## FAQs

### Why use [enumerated types](https://www.postgresql.org/docs/12/datatype-enum.html) when you could've just used a `varchar`?

Efficiency aside, the main reason is to allow [ordering by _rank_ rather than
alphabetic position](https://www.postgresql.org/docs/12/datatype-enum.html#id-1.5.7.15.6).

## Nomenclature

| Word                                                         | Definition                                                                                                                                                     |
| --------------                                               | ----------                                                                                                                                                     |
| EduBase                                                      | The old name for [Get information about schools](https://get-information-schools.service.gov.uk/) (GIAS)                                                       |
| [Ofsted](https://www.gov.uk/government/organisations/ofsted) | The Office for Standards in Education, Children's Services and Skills (Ofsted) is a non-ministerial department of the UK government, reporting to Parliament.A |
| [URN](https://en.wikipedia.org/wiki/Unique_Reference_Number) | A six-digit number used by the UK government to identify educational establishments in the United Kingdom.                                                     |

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

### "List all the currently-open schools in London excluding those in Kensington and Chelsea, Southwark, and Tower Hamlets" 🤨

```sql
with local_authorities_to_exclude as (
  select
    st_union(edge) as edges                  -- union multiple edges into a single geometry
  from
    local_authorities
  where
    name in (
      'Kensington and Chelsea',
      'Southwark',
      'Tower Hamlets'
    )
)
select
  distinct on (urn)
  os.urn,
  os.name,
  os.coordinates
from
  open_schools os
inner join                                   -- join on region containing coordinates
  regions r
    on st_contains(
      r.edge,
      os.coordinates::geometry
    )
inner join                                   -- exclude the named LAs from above
  local_authorities la
    on not st_contains(
      (select edges from local_authorities_to_exclude),
      os.coordinates::geometry
    )
where
  r.name = 'London'
;
```

There are too many results to list, but here's a screenshot displaying the results in
[QGIS](https://qgis.org/). Note that QGIS fully supports PostGIS, all queries that
include a geospatial column can be displayed and manipulated by the software and used
to [create reports](https://docs.qgis.org/3.10/en/docs/user_manual/print_composer/create_reports.html) or
perform [advanced queries](https://www.qgistutorials.com/en/docs/performing_spatial_queries.html).

![Schools in London minus Kensington and Chelsea, Tower Hamlets and Southwark](docs/images/london-schools.png)

# (Unofficial) GIAS Query Toolkit

Ever wanted to write a quick query against the [Get Information About
Schools](https://get-information-schools.service.gov.uk/) dataset but couldn't
because it's provided in an unwieldy CSV file that's not properly-encoded and
has too many columns?

Great, you're in the right place!

## Example queries



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

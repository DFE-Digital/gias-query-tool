1. download

	wget https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata20200328.csv

2. cleanse

	scripts/cleanse < edubasealldata20200328.csv > edubasealldata20200328-cleansed.csv

3. fix line endings

	scripts/fix-line-endings < edubasealldata20200328.csv > edubasealldata20200328-cleansed.csv

4. generate create table statement using csvsql

	csvsql -v -i postgresql edubasealldata20200328-cleansed.csv > out.sql
	
5. create a new empty database

	createdb gias

6. create table for raw data

	psql gias < ddl/create-holding-table.sql

7. copy data

	psql gias --command "\copy schools_raw from 'edubasealldata20200328-cleansed-fixed.csv' with csv header"

8. build final dataset

9. drop holding table and cleanup

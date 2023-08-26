today:=$(shell date "+%Y%m%d")
gias_filename:=edubasealldata${today}.csv
fixed_filename=edubasealldata${today}-fixed.csv
test_filename=edubasealldata${today}-fixed-test-set.csv
database_name=gias
pg_host=localhost
pg_port=5432
pg_username=${USER}
psql_connection_string=postgres://${pg_username}@${pg_host}:${pg_port}/${database_name}
psql_command=psql -q -d ${psql_connection_string}
psql_base_url=$(shell echo $(psql_connection_string) | sed 's/\/[^\/]*$$//')
data_dir=tmp
export_dir=tmp/export
gcs_bucket=rugged-abacus-uploads
bq_dataset=gias
current_git_sha:=$(shell git rev-parse HEAD)

build_docker: api_db
	# linux/amd64 as this is required for Teacher Services Cloud
	docker build --platform=linux/amd64 -t "ghcr.io/dfe-digital/gias-api:${current_git_sha}" .

push_docker:
	docker push ghcr.io/dfe-digital/gias-api:${current_git_sha}

deploy:
	# this is a temporary task while we get set up
	AUTO_APPROVE=-auto-approve DOCKER_IMAGE_TAG=${current_git_sha} make -f tsc.mk development terraform-apply

reload: ${data_dir}/${fixed_filename} refresh

refresh: drop_database           \
		 create_database         \
		 create_postgis          \
		 create_types            \
		 create_holding_tables   \
		 populate_holding_tables \
		 create_data_tables      \
		 populate_data_tables    \
		 drop_holding_tables     \
		 create_views            \
		 refresh_views

${data_dir}/${gias_filename}:
	rm -f tmp/*.csv
	wget https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/${gias_filename} --directory-prefix=${data_dir}

${data_dir}/${fixed_filename}: ${data_dir}/${gias_filename}
	iconv -f ISO8859-1 -t UTF-8 $^ > $@

${data_dir}/${test_filename}: ${data_dir}/${fixed_filename}
	head -n 101 $^ > $@ # 100 schools plus header row

.PHONY: api_db
api_db: reload db/gias.sqlite3 test_db

test_db: ${data_dir}/${test_filename}
	$(MAKE) database_name=gias_test fixed_filename=${test_filename} refresh
	$(MAKE) database_name=gias_test db/gias_test.sqlite3

drop_database:
	-psql ${psql_base_url} -qc "DROP DATABASE ${database_name};"

create_database:
	psql ${psql_base_url} -qc "CREATE DATABASE ${database_name};"

create_postgis:
	${psql_command} < ddl/extensions/postgis.sql

create_holding_tables:
	${psql_command} < ddl/tables/create_schools_raw.sql
	${psql_command} < ddl/tables/create_email_addresses_raw.sql
	${psql_command} < ddl/tables/create_deprivation_pupil_premium_raw.sql
	${psql_command} < ddl/tables/geo/create_electoral_regions_raw.sql
	${psql_command} < ddl/tables/geo/create_local_authority_districts_raw.sql

create_types:
	${psql_command} < ddl/types/establishment.sql
	${psql_command} < ddl/types/establishment_group.sql
	${psql_command} < ddl/types/gender.sql
	${psql_command} < ddl/types/ofsted_rating.sql
	${psql_command} < ddl/types/phase.sql
	${psql_command} < ddl/types/rural_urban_classification.sql
	${psql_command} < ddl/types/government_office_regions.sql

create_data_tables:
	${psql_command} < ddl/tables/create_schools.sql
	${psql_command} < ddl/tables/create_deprivation_pupil_premium.sql
	${psql_command} < ddl/tables/geo/create_regions.sql
	${psql_command} < ddl/tables/geo/create_local_authorities.sql

create_views:
	${psql_command} < ddl/views/open_schools.sql

populate_holding_tables:
	${psql_command} --command "\copy schools_raw from 'tmp/${fixed_filename}' with csv header"
	${psql_command} < dml/import_email_addresses_raw.sql
	${psql_command} < dml/import_deprivation_pupil_premium_raw.sql
	${psql_command} < dml/geo/import_electoral_regions.sql
	${psql_command} < dml/geo/import_local_authority_districts.sql

drop_holding_tables:
	${psql_command} < ddl/tables/drop_schools_raw.sql
	${psql_command} < ddl/tables/drop_email_addresses_raw.sql
	${psql_command} < ddl/tables/drop_deprivation_pupil_premium_raw.sql
	${psql_command} < ddl/tables/geo/drop_electoral_regions_raw.sql
	${psql_command} < ddl/tables/geo/drop_local_authority_districts_raw.sql

populate_data_tables:
	${psql_command} < dml/import_schools.sql
	${psql_command} < dml/import_deprivation_pupil_premium.sql
	${psql_command} < dml/geo/import_regions.sql
	${psql_command} < dml/geo/import_districts.sql

refresh_views:
	${psql_command} < ddl/refresh/refresh_open_schools.sql

db/%.sqlite3:
	bundle exec sequel -C ${psql_connection_string} sqlite://$@
	sqlite3 $@ 'CREATE VIEW open_schools AS SELECT * FROM schools WHERE open'

export_views := $(shell psql ${database_name} -XtAc "SELECT matviewname FROM pg_catalog.pg_matviews WHERE schemaname NOT LIKE 'pg_%';")
export_tables := $(shell psql ${database_name} -XtAc "SELECT tablename FROM pg_catalog.pg_tables WHERE schemaname='public' AND tablename NOT IN ('local_authorities', 'regions');")

export_view_files := $(addprefix ${data_dir}/export/, $(addsuffix .csv, ${export_views}))
export_table_files := $(addprefix ${data_dir}/export/, $(addsuffix .csv, ${export_tables}))

${data_dir}/export/%.csv : 
	@mkdir -p $(data_dir)/export
	@echo "Extracting table $*"
	@psql ${database_name} -XtAc "COPY $* TO STDOUT WITH (FORMAT csv, HEADER)" > $@

${data_dir}/export/%.csv : 
	@mkdir -p $(data_dir)/export
	@echo "Extracting view $*"
	@psql ${database_name} -XtAc "COPY (SELECT * FROM $*) TO STDOUT WITH (FORMAT csv, HEADER)" > $@

schema_files := $(addprefix ${data_dir}/export/, $(addsuffix .schema.json, ${export_tables} ${export_views}))

${data_dir}/export/%.schema.json : ${data_dir}/export/%.csv
	@echo "Generating schema for $*"
	@generate-schema --input_format csv < $^ > $@

generate_schemas: ${schema_files} ${export_table_files} ${export_view_files}

clean_export:
	rm -rf ${export_dir}

.PHONY=upload_to_gcs load_to_bq

upload_to_gcs: ${export_table_files} ${export_view_files}
	@for file in $^; do \
		echo "Uploading $$file to GCS"; \
		gcloud storage cp $$file gs://${gcs_bucket}/gias/`basename $$file`; \
	done

load_to_bq: ${export_table_files} ${export_view_files} generate_schemas upload_to_gcs
	@for file in $^; do \
		if [[ $$file == *.csv ]]; then \
			echo "Loading $$file to BigQuery"; \
			table=`basename $$file .csv`; \
			bq load --source_format=CSV --skip_leading_rows=1 --schema=${data_dir}/export/$$table.schema.json ${bq_dataset}.$$table gs://${gcs_bucket}/gias/$$table.csv; \
		fi \
	done

docs:
	redocly build-docs config/gias_api_v1.yml --output=docs/api-docs.html

psql_command=psql -q
today:=$(shell date "+%Y%m%d")
gias_filename:=edubasealldata${today}.csv
fixed_filename=edubasealldata${today}-fixed.csv
database_name=gias
data_dir=tmp

reload: download_gias_data refresh

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

download_gias_data:
	rm -f tmp/*.csv
	wget https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/${gias_filename} --directory-prefix=${data_dir}
	iconv tmp/${gias_filename} -f ISO8859-1 -t utf8 -o tmp/${fixed_filename}

drop_database:
	dropdb --if-exists ${database_name}

create_database:
	createdb ${database_name}

create_postgis:
	${psql_command} ${database_name} < ddl/extensions/postgis.sql

create_holding_tables:
	${psql_command} ${database_name} < ddl/tables/create_schools_raw.sql
	${psql_command} ${database_name} < ddl/tables/create_email_addresses_raw.sql
	${psql_command} ${database_name} < ddl/tables/create_deprivation_pupil_premium_raw.sql
	${psql_command} ${database_name} < ddl/tables/geo/create_electoral_regions_raw.sql
	${psql_command} ${database_name} < ddl/tables/geo/create_local_authority_districts_raw.sql

create_types:
	${psql_command} ${database_name} < ddl/types/establishment.sql
	${psql_command} ${database_name} < ddl/types/establishment_group.sql
	${psql_command} ${database_name} < ddl/types/gender.sql
	${psql_command} ${database_name} < ddl/types/ofsted_rating.sql
	${psql_command} ${database_name} < ddl/types/phase.sql
	${psql_command} ${database_name} < ddl/types/rural_urban_classification.sql

create_data_tables:
	${psql_command} ${database_name} < ddl/tables/create_schools.sql
	${psql_command} ${database_name} < ddl/tables/create_deprivation_pupil_premium.sql
	${psql_command} ${database_name} < ddl/tables/geo/create_regions.sql
	${psql_command} ${database_name} < ddl/tables/geo/create_local_authorities.sql

create_views:
	${psql_command} ${database_name} < ddl/views/open_schools.sql

populate_holding_tables:
	${psql_command} ${database_name} --command "\copy schools_raw from 'tmp/${fixed_filename}' with csv header"
	${psql_command} ${database_name} < dml/import_email_addresses_raw.sql
	${psql_command} ${database_name} < dml/import_deprivation_pupil_premium_raw.sql
	${psql_command} ${database_name} < dml/geo/import_electoral_regions.sql
	${psql_command} ${database_name} < dml/geo/import_local_authority_districts.sql

drop_holding_tables:
	${psql_command} ${database_name} < ddl/tables/drop_schools_raw.sql
	${psql_command} ${database_name} < ddl/tables/drop_email_addresses_raw.sql
	${psql_command} ${database_name} < ddl/tables/drop_deprivation_pupil_premium_raw.sql
	${psql_command} ${database_name} < ddl/tables/geo/drop_electoral_regions_raw.sql
	${psql_command} ${database_name} < ddl/tables/geo/drop_local_authority_districts_raw.sql

populate_data_tables:
	${psql_command} ${database_name} < dml/import_schools.sql
	${psql_command} ${database_name} < dml/import_deprivation_pupil_premium.sql
	${psql_command} ${database_name} < dml/geo/import_regions.sql
	${psql_command} ${database_name} < dml/geo/import_districts.sql

refresh_views:
	${psql_command} ${database_name} < ddl/refresh/refresh_open_schools.sql

serve:
	bundle exec ruby server.rb

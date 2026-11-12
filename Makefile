psql_command=psql -q
today:=$(shell date "+%Y%m%d")
gias_schools_file:=edubasealldata${today}.csv
gias_links_file:=links_edubasealldata${today}.csv
fixed_school_filename=edubasealldata${today}-fixed.csv
fixed_links_filename=links_edubasealldata${today}-fixed.csv
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

download_gias_data: clear_tmp_csvs download_schools_data download_school_links_data

clear_tmp_csvs:
	rm -f tmp/*.csv

download_schools_data:
	wget https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/${gias_schools_file} --directory-prefix=${data_dir}
	iconv -f ISO8859-1 -t UTF-8 tmp/${gias_schools_file} > tmp/${fixed_school_filename}

download_school_links_data:
	wget https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/${gias_links_file} --directory-prefix=${data_dir}
	iconv -f ISO8859-1 -t UTF-8 tmp/${gias_links_file} > tmp/${fixed_links_filename}

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
	${psql_command} ${database_name} < ddl/tables/create_school_links_raw.sql

create_types:
	${psql_command} ${database_name} < ddl/types/establishment.sql
	${psql_command} ${database_name} < ddl/types/establishment_group.sql
	${psql_command} ${database_name} < ddl/types/gender.sql
	${psql_command} ${database_name} < ddl/types/phase.sql
	${psql_command} ${database_name} < ddl/types/rural_urban_classification.sql
	${psql_command} ${database_name} < ddl/types/government_office_regions.sql
	${psql_command} ${database_name} < ddl/types/link_types.sql

create_data_tables:
	${psql_command} ${database_name} < ddl/tables/create_schools.sql
	${psql_command} ${database_name} < ddl/tables/create_deprivation_pupil_premium.sql
	${psql_command} ${database_name} < ddl/tables/geo/create_regions.sql
	${psql_command} ${database_name} < ddl/tables/geo/create_local_authorities.sql
	${psql_command} ${database_name} < ddl/tables/create_school_links.sql

create_views:
	${psql_command} ${database_name} < ddl/views/open_schools.sql

populate_holding_tables:
	${psql_command} ${database_name} --command "\copy schools_raw from 'tmp/${fixed_school_filename}' with csv header"
	${psql_command} ${database_name} --command "\copy school_links_raw from 'tmp/${fixed_links_filename}' with csv header"
	${psql_command} ${database_name} < dml/import_email_addresses_raw.sql
	${psql_command} ${database_name} < dml/import_deprivation_pupil_premium_raw.sql
	${psql_command} ${database_name} < dml/geo/import_electoral_regions.sql
	${psql_command} ${database_name} < dml/geo/import_local_authority_districts.sql

drop_holding_tables:
	${psql_command} ${database_name} < ddl/tables/drop_schools_raw.sql
	${psql_command} ${database_name} < ddl/tables/drop_email_addresses_raw.sql
	${psql_command} ${database_name} < ddl/tables/drop_school_links_raw.sql
	${psql_command} ${database_name} < ddl/tables/drop_deprivation_pupil_premium_raw.sql
	${psql_command} ${database_name} < ddl/tables/geo/drop_electoral_regions_raw.sql
	${psql_command} ${database_name} < ddl/tables/geo/drop_local_authority_districts_raw.sql

populate_data_tables:
	${psql_command} ${database_name} < dml/import_schools.sql
	${psql_command} ${database_name} < dml/import_deprivation_pupil_premium.sql
	${psql_command} ${database_name} < dml/geo/import_regions.sql
	${psql_command} ${database_name} < dml/geo/import_districts.sql
	${psql_command} ${database_name} < dml/import_school_links.sql

refresh_views:
	${psql_command} ${database_name} < ddl/refresh/refresh_open_schools.sql

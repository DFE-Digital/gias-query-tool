psql_command=psql -q
today:=$(shell date "+%Y%m%d")
gias_filename:=edubasealldata${today}.csv
clean_filename=fixed.csv
fixed_filename=fixed_and_cleansed.csv
database_name=gias
data_dir=tmp

reload: download_gias_data refresh

refresh: drop_database          \
		 create_database        \
		 create_types           \
		 create_holding_table   \
		 populate_holding_table \
		 create_schools_table   \
		 create_views           \
		 import


download_gias_data:
	rm tmp/*.csv
	wget https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/${gias_filename} --directory-prefix=${data_dir}
	./scripts/cleanse < tmp/${gias_filename} > tmp/${clean_filename}
	./scripts/fix-line-endings < tmp/${clean_filename} > tmp/${fixed_filename}

drop_database:
	dropdb --if-exists ${database_name}

create_database:
	createdb ${database_name}

create_holding_table:
	${psql_command} ${database_name} < ddl/tables/schools_raw.sql

create_types:
	${psql_command} ${database_name} < ddl/types/establishment.sql
	${psql_command} ${database_name} < ddl/types/establishment_group.sql
	${psql_command} ${database_name} < ddl/types/gender.sql
	${psql_command} ${database_name} < ddl/types/ofsted_rating.sql
	${psql_command} ${database_name} < ddl/types/phase.sql

create_schools_table:
	${psql_command} ${database_name} < ddl/tables/schools.sql

create_views:
	${psql_command} ${database_name} < ddl/views/open_schools.sql

populate_holding_table:
	${psql_command} ${database_name} --command "\copy schools_raw from 'tmp/${fixed_filename}' with csv header"

import:
	${psql_command} ${database_name} < dml/import.sql

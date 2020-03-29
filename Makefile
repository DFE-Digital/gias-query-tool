psql_command=psql -q
database_name=gias

refresh:	drop_database          \
		 	create_database        \
			create_types           \
			create_holding_table   \
			populate_holding_table \
			create_schools_table   \
			import

drop_database:
	dropdb ${database_name}

create_database:
	createdb ${database_name}

create_holding_table:
	${psql_command} ${database_name} < ddl/create-holding-table.sql

create_types:
	${psql_command} ${database_name} < ddl/types/establishment.sql
	${psql_command} ${database_name} < ddl/types/establishment_group.sql

create_schools_table:
	${psql_command} ${database_name} < ddl/create-schools-table.sql

populate_holding_table:
	${psql_command} ${database_name} --command "\copy schools_raw from 'tmp/edubasealldata20200328-cleansed-fixed.csv' with csv header"

import:
	${psql_command} ${database_name} < dml/import.sql

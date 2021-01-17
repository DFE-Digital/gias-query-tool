require "pg"
require "sequel"
require "logger"
require "blueprinter"

DB = Sequel.connect("postgres://gias:gias@127.0.0.1:5432/gias", max_connections: 10)

require_relative "models/school"
require_relative "serialisers/school"

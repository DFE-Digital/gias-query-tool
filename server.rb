require "sinatra"
require_relative "api/api"

before { content_type(:json) }

get("/schools") do
  schools = Models::School.all

  Serialisers::School.render(schools)
end

get("/schools/open") do
  schools = Models::OpenSchool.all

  Serialisers::School.render(schools)
end

get("/schools/:urn") do |urn|
  halt(400) unless urn =~ /[0-9]+/

  school = Models::School.find(urn: urn)

  halt(404) unless school

  Serialisers::School.render(school)
end

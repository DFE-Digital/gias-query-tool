require 'sinatra'
require 'active_support'
require 'sinatra/activerecord'

$LOAD_PATH.unshift "#{settings.root}/lib"

require 'openapi3'

module SerializableSchool
  def as_json
    attrs = super.except('urn', 'coordinates')
    { data: { id: urn, type: 'school', attributes: attrs } }
  end
end

class School < ActiveRecord::Base
  include SerializableSchool
end

class OpenSchool < ActiveRecord::Base
  include SerializableSchool
end

class GIASApi < Sinatra::Base
  before '/api/*' do
    content_type 'application/json'
  end

  get '/' do
    send_file './docs/api-docs.html'
  end

  get '/api/schools' do
    { data: School.all.as_json }.to_json
  end

  get '/api/open_schools' do
    { data: OpenSchool.all.as_json }.to_json
  end

  get '/api/schools/:id' do
    school = School.find(params[:id])

    { data: school.as_json }.to_json
  rescue ActiveRecord::RecordNotFound
    halt(404)
  end
end

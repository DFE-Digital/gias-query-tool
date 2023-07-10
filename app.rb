require 'sinatra'
require 'active_support'
require 'sinatra/activerecord'

class School < ActiveRecord::Base
  def as_json
    attrs = super.except('urn', 'coordinates')
    { id: urn, type: 'school', attributes: attrs }
  end
end

class GIASApi < Sinatra::Base
  before '/api/*' do
    content_type 'application/json'
  end

  get '/api/schools' do
    School.first(10).as_json.to_json
  end
end

require 'sinatra'
require 'active_support'
require 'sinatra/activerecord'

$LOAD_PATH.unshift settings.root + '/lib'

class School < ActiveRecord::Base
  def as_json
    attrs = super.except('urn', 'coordinates')
    {data: { id: urn, type: 'school', attributes: attrs }}
  end
end

class GIASApi < Sinatra::Base
  before '/api/*' do
    content_type 'application/json'
  end

  get '/api/schools' do
    { data: School.first(10).as_json }.to_json
  end
end

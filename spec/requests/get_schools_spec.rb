require 'spec_helper'
require 'json'

RSpec.describe 'GET /schools' do
  it 'returns a list of schools' do
    get '/api/schools'
    expect(last_response.status).to eq(200)

    resp = JSON.parse(last_response.body)
    expect(resp['data'].length).to eq(100)

    expect(resp).to be_valid_against_openapi_schema('SchoolList')
  end
end

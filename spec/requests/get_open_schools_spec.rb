require 'spec_helper'
require 'json'

RSpec.describe 'GET /open_schools' do
  it 'returns a list of open schools' do
    expect(OpenSchool.count).to be > 0
    get '/api/open_schools'
    expect(last_response.status).to eq(200)

    resp = JSON.parse(last_response.body)
    expect(resp['data'].length).to eq(OpenSchool.count)

    expect(resp).to be_valid_against_openapi_schema('SchoolList')
  end
end

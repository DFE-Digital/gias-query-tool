require 'spec_helper'
require 'json'

RSpec.describe 'GET /open_schools' do
  it 'returns a list of open schools' do
    get '/api/open_schools'
    expect(last_response.status).to eq(200)

    resp = JSON.parse(last_response.body)
    resp['data'].each do |item|
      expect(item['attributes']['open']).to be(true)
    end

    expect(resp).to be_valid_against_openapi_schema('SchoolList')
  end
end

require 'spec_helper'
require 'json'
require 'csv'

RSpec.describe 'GET /open_schools' do
  let(:open_school_count) do
    CSV
      .read(Dir.glob('tmp/*test-set*').pop, headers: true)
      .map { |r| r['EstablishmentStatus (name)'] }
      .count('Open')
  end

  let(:resp) do
    JSON.parse(last_response.body)
  end

  before { get '/api/open_schools' }

  it('returns with success') do
    expect(last_response.status).to eq(200)
  end

  it 'only returns open schools' do
    resp['data'].each do |item|
      expect(item['attributes']['open']).to be(true)
    end
  end

  it 'returns all open schools' do
    expect(resp['data'].length).to eq(open_school_count)
  end

  it 'is valid against openapi schema' do
    expect(resp).to be_valid_against_openapi_schema('SchoolList')
  end
end

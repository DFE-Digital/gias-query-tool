require 'spec_helper'

RSpec.describe 'GET /schools' do
  it 'returns a list of schools' do
    get '/api/schools'
    expect(last_response.status).to eq(200)
  end
end

require 'spec_helper'

RSpec.describe 'GET /schools', type: :request do
  it 'returns a list of schools' do
    get '/api/schools'
    expect(last_response.status).to eq(200)
  end
end

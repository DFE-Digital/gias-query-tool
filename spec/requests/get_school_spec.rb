RSpec.describe 'GET /schools/:id' do
  it 'returns a school' do
    get '/api/schools/100000'
    expect(last_response.status).to eq(200)

    resp = JSON.parse(last_response.body)

    expect(resp).to be_valid_against_openapi_schema('School')
  end

  it 'returns 404 when appropriate' do
    get '/api/schools/invalid'
    expect(last_response.status).to eq(404)
  end
end

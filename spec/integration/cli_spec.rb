require 'faraday'
require 'fileutils'

describe "The pact-mock-service command line interface", mri_only: true do

  let(:expected_interaction) do
    {
      description: "a request for a greeting",
      request: {
        method: :get,
        path: '/greeting'
      },
      response: {
        status: 200,
        headers: { 'Content-Type' => 'text/plain' },
        body: "Hello world"
      }
    }.to_json
  end

  let(:mock_service_headers) do
    {
      'Content-Type' => 'application/json',
      'X-Pact-Mock-Service' => 'true'
    }
  end

  let(:pact_details) do
    {
      consumer: { name: 'Consumer' },
      provider: { name: 'Provider' }
    }.to_json
  end

  before :all do
    FileUtils.rm_rf 'tmp'
    FileUtils.rm_rf 'tmp/integration.log'
    FileUtils.rm_rf 'tmp/pacts'

    @@pid = nil
    @@pid = fork do
      exec "bundle exec bin/pact-mock-service --port 1234 --log tmp/integration.log --pact-dir tmp/pacts"
    end

    tries = 0
    begin
      Faraday.delete "http://localhost:1234/interactions", nil, {'X-Pact-Mock-Service' => 'true'}
    rescue Faraday::ConnectionFailed => e
      sleep 0.1
      tries += 1
      retry if tries < 50
    end

  end

  it "starts up and responds with mocked responses" do

    response = Faraday.post "http://localhost:1234/interactions",
      expected_interaction,
      mock_service_headers

    expect(response.status).to eq 200

    response = Faraday.get "http://localhost:1234/greeting",
      nil

    expect(response.status).to eq 200
    expect(response.body).to eq 'Hello world'

    response = Faraday.post "http://localhost:1234/pact",
          pact_details,
          mock_service_headers

    expect(response.status).to eq 200
  end

  it "writes logs to the specified log file" do
    expect(File.exist?('tmp/integration.log')).to be true
  end

  it "writes the pact to the specified directory" do
    expect(File.exist?('tmp/pacts/consumer-provider.json')).to be true
  end

  after :all do
    if @@pid
      Process.kill "INT", @@pid
    end
  end
end

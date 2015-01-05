require 'faraday'
require 'fileutils'

describe "The pact-mock-service command line interface, with SSL", mri_only: true do

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

    @@ssl_pid = nil
    @@ssl_pid = fork do
      exec "bundle exec bin/pact-mock-service --port 4343 --ssl --log tmp/integration.log --pact-dir tmp/pacts"
    end

  end

  it "should respond with SSL" do
    tries = 0
    begin
      connection = Faraday.new "https://localhost:4343", ssl: { verify: false }
      response = connection.delete "/interactions", nil, {'X-Pact-Mock-Service' => 'true'}
      puts response.inspect
      expect(response.status).to eq 200
    rescue Faraday::ConnectionFailed => e
      sleep 0.1
      tries += 1
      retry if tries < 50
      expect(tries < 50).to be true
    end
  end


  after :each do
    if @@ssl_pid
      Process.kill "INT", @@ssl_pid
    end
  end
end

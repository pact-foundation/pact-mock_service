require 'fileutils'
require 'support/integration_spec_support'

module Pact
  module ControlServerTestSupport
    include IntegrationTestSupport

    def mock_service_headers
      {
        'Content-Type' => 'application/json',
        'X-Pact-Mock-Service' => 'true',
        'X-Pact-Consumer' => 'Consumer',
        'X-Pact-Provider' => 'Provider'
      }
    end
  end
end

describe "The pact-mock-service control server command line interface", mri_only: true do

  include Pact::ControlServerTestSupport

  before :all do
    clear_dirs
    @pid = start_control 1234, "--pact-specification-version 3"
  end

  it "starts up and responds with mocked responses" do
    response = setup_interaction 1234
    puts response.body unless response.status == 200
    expect(response.status).to eq 200
    mock_service_port = URI(response.headers['X-Pact-Mock-Service-Location']).port
    expect(mock_service_port).to_not eq 1234

    response = invoke_expected_request mock_service_port
    expect(response.status).to eq 200
    expect(response.body).to eq 'Hello world'

    Process.kill "INT", @pid
    sleep 1 # Naughty, but so much less code
    @pid = nil
  end

  it "writes logs to the specified log file" do
    expect(Dir.glob('tmp/log/*.log').size).to be 1
  end

  it "writes the pact to the specified directory" do
    expect(File.exist?('tmp/pacts/consumer-provider.json')).to be true
  end

  it "writes the pacts with the specified in pact specification version" do
    expect(JSON.parse(File.read('tmp/pacts/consumer-provider.json'))['metadata']['pactSpecification']['version']).to eq '3.0.0'
  end

  after :all do
    kill_server @pid
  end
end

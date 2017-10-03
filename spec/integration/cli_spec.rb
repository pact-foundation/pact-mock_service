require 'fileutils'
require 'support/integration_spec_support'

describe "The pact-mock-service command line interface", mri_only: true do

  include Pact::IntegrationTestSupport

  before :all do
    clear_dirs
    @pid = start_server 1234
  end

  it "starts up and responds with mocked responses" do
    response = setup_interaction 1234
    expect(response.status).to eq 200

    response = invoke_expected_request 1234
    puts response.body if response.status != 200
    expect(response.status).to eq 200
    expect(response.body).to eq 'Hello world'

    write_pact 1234
    expect(response.status).to eq 200
  end

  it "sets the X-Pact-Mock-Service-Location header" do
    response = setup_interaction 1234
    expect(response.headers['X-Pact-Mock-Service-Location']).to eq 'http://0.0.0.0:1234'
  end

  it "writes logs to the specified log file" do
    expect(File.exist?('tmp/integration.log')).to be true
  end

  it "writes the pact to the specified directory" do
    expect(File.exist?('tmp/pacts/consumer-provider.json')).to be true
  end

  after :all do
    kill_server @pid
  end
end

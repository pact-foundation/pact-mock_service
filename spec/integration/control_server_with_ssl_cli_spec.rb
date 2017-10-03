require 'fileutils'
require 'support/integration_spec_support'

describe "The pact-mock-service control server command line interface", mri_only: true do

  include Pact::ControlServerTestSupport

  before :all do
    clear_dirs
    @pid = start_control 1234, '--ssl'
  end

  it "sets the X-Pact-Mock-Service-Location with https" do
    response = setup_interaction 1234
    expect(response.headers['X-Pact-Mock-Service-Location']).to start_with 'https://localhost:'
  end

  it "responds to an OPTIONS request for a non administration request" do
    response = setup_interaction 1234
    expect(response.status).to eq 200
    mock_service_port = URI(response.headers['X-Pact-Mock-Service-Location']).port
    response = connect_via_ssl mock_service_port
    expect(response.status).to eq 200
  end

  after :all do
    kill_server @pid
  end
end

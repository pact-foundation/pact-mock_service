require 'fileutils'
require 'support/integration_spec_support'

describe "The pact-mock-service control server command line interface", mri_only: true, skip_windows: true do

  include Pact::ControlServerTestSupport

  before :all do
    clear_dirs
    @pid = start_control 8888, '--cors'
  end

  it "responds to an OPTIONS request for a non administration request" do
    response = setup_interaction 8888
    expect(response.status).to eq 200
    mock_service_port = URI(response.headers['X-Pact-Mock-Service-Location']).port

    response = make_options_request mock_service_port
    expect(response.status).to eq 200
    expect(response.headers['Access-Control-Allow-Headers']).to_not be nil
  end

  after :all do
    kill_server @pid
  end
end

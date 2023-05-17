require 'faraday'
require 'fileutils'
require 'support/integration_spec_support'

describe "The pact-mock-service command line interface", mri_only: true, skip_windows: true do

  include Pact::IntegrationTestSupport

  before :all do
    clear_dirs
    @pid = start_server 8888, '--cors'
  end

  it "responds to an OPTIONS request for a non administration request" do
    response = make_options_request 8888
    expect(response.status).to eq 200
    expect(response.headers['Access-Control-Allow-Headers']).to_not be nil
  end

  after :all do
    kill_server @pid
  end
end

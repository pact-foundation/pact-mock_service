require 'faraday'
require 'fileutils'
require 'support/integration_spec_support'

describe "The pact-mock-service command line interface", mri_only: true do

  include Pact::IntegrationTestSupport

  before :all do
    FileUtils.rm_rf 'tmp'

    @pid = nil
    @pid = fork do
      exec "bundle exec bin/pact-mock-service --cors --port 1234 --log tmp/integration.log --pact-dir tmp/pacts"
    end

    wait_until_server_started 1234
  end

  it "responds to an OPTIONS request for a non administration request" do
    response = make_options_request 1234
    expect(response.status).to eq 200
    expect(response.headers['Access-Control-Allow-Headers']).to_not be nil
  end

  after :all do
    if @pid
      Process.kill "INT", @pid
    end
  end
end

require 'faraday'
require 'fileutils'
require 'support/integration_spec_support'

describe "The pact-mock-service command line interface, with SSL", mri_only: true do

  include Pact::IntegrationTestSupport

  before :all do
    FileUtils.rm_rf 'tmp'

    @pid = nil
    @pid = fork do
      exec "bundle exec bin/pact-mock-service --port 4343 --ssl --log tmp/integration.log --pact-dir tmp/pacts"
    end
  end

  it "should respond with SSL" do
    tries = 0
    begin
      response = connect_via_ssl 4343
      expect(response.status).to eq 200
    rescue Faraday::ConnectionFailed => e
      sleep 0.1
      tries += 1
      retry if tries < 100
      expect(tries < 100).to be true
    end
  end

  after :each do
    if @pid
      Process.kill "INT", @pid
    end
  end
end

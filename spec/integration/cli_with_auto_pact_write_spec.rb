require 'faraday'
require 'fileutils'
require 'support/integration_spec_support'

describe "The pact-mock-service command line interface", mri_only: true do

  include Pact::IntegrationTestSupport

  before :all do
    FileUtils.rm_rf 'tmp'

    @pid = nil
    @pid = fork do
      exec "bundle exec bin/pact-mock-service --consumer Consumer --provider Provider --port 1235 --log tmp/integration.log --pact-dir tmp/pacts"
    end

    wait_until_server_started 1235

  end

  context "when the consumer and provider names are provided" do
    it "writes the pact to the specified directory on shutdown" do
      response = setup_interaction 1235
      expect(response.status).to eq 200

      response = invoke_expected_request 1235
      expect(response.status).to eq 200

      Process.kill "INT", @pid
      sleep 1 # Naughty, but so much less code!
      @pid = nil
      expect(File.exist?('tmp/pacts/consumer-provider.json')).to be true
    end

    after :all do
      if @pid
        Process.kill "INT", @pid
        Process.wait @pid
      end
    end
  end
end

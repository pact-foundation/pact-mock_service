require 'fileutils'
require 'support/integration_spec_support'
require 'find_a_port'

describe "The pact-mock-service command line interface", mri_only: true do

  include Pact::IntegrationTestSupport

  before :all do
    clear_dirs
    @port = FindAPort.available_port
    @pid = start_server @port, '--consumer Consumer --provider Provider'
  end

  context "when the consumer and provider names are provided" do
    it "writes the pact to the specified directory on shutdown" do
      expect(File.exist?('tmp/pacts/consumer-provider.json')).to be false
      response = setup_interaction @port
      expect(response.status).to eq 200

      response = invoke_expected_request @port
      expect(response.status).to eq 200

      Process.kill "INT", @pid
      sleep 1 # Naughty, but so much less code!
      @pid = nil
      expect(File.exist?('tmp/pacts/consumer-provider.json')).to be true
    end

    after :all do
      kill_server @pid
    end
  end
end

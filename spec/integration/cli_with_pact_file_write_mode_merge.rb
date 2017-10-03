require 'fileutils'
require 'support/integration_spec_support'

describe "The pact-mock-service command line interface", mri_only: true do

  include Pact::IntegrationTestSupport

  before :all do
    clear_dirs
    @pid = start_server 2235, '--pact-file-write-mode merge --log tmp/integration1.log'
    @pid2 = start_server 2236, '--pact-file-write-mode merge --log tmp/integration2.log'
  end

  context "when pact-file-write-mode is merge" do
    it "writes the pact to the specified directory on shutdown" do
      response = setup_interaction 2235
      response = invoke_expected_request 2235
      response = setup_another_interaction 2236
      response = invoke_another_expected_request 2236
      write_pact(2235)
      write_pact(2236)
      expect(JSON.parse(File.read('tmp/pacts/consumer-provider.json'))['interactions'].size).to eq 2
    end
  end

  after :all do
    kill_server @pid
    kill_server @pid2
  end
end

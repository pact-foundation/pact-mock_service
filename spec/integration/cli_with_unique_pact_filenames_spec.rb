require 'fileutils'
require 'support/integration_spec_support'

describe "The pact-mock-service command line interface", mri_only: true do

  include Pact::IntegrationTestSupport

  before :all do
    FileUtils.rm_rf 'tmp/pacts'
    @pid = start_server 2235, '--unique-pact-file-names true'
  end

  context "when unique-pact-file-names is true" do
    it "writes the pact to the specified directory on shutdown" do
      response = setup_interaction 2235
      response = invoke_expected_request 2235
      write_pact(2235).body
      expect(Dir.glob('tmp/pacts/*.json')[0]).to match /consumer\-provider\-\d+.json/
    end
  end

  after :all do
    kill_server @pid
  end
end

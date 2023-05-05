require 'support/integration_spec_support'
require 'find_a_port'

describe "The pact-stub-service command line interface with multiple pacts", mri_only: true, skip_windows: true do

  include Pact::IntegrationTestSupport

  before :all do
    clear_dirs
    @port = FindAPort.available_port
    @pid = start_stub_server @port, "spec/support/pact-for-stub-1.json spec/support/pact-for-stub-2.json"
  end

  it "includes the interactions from the first pact file" do
    response = Faraday.get "http://localhost:#{@port}/path1"
    puts response.body if response.status != 200
    expect(response.status).to eq 200
  end

  it "includes the interactions from the second pact file" do
    response = Faraday.get "http://localhost:#{@port}/path2"
    puts response.body if response.status != 200
    expect(response.status).to eq 200
  end

  after :all do
    kill_server @pid
  end
end

require 'support/integration_spec_support'

describe "The pact-stub-service command line interface with multiple pacts", mri_only: true do

  include Pact::IntegrationTestSupport

  PORT = 5556

  before :all do
    clear_dirs
    @pid = start_stub_server PORT, "spec/support/pact-for-stub-1.json spec/support/pact-for-stub-2.json"
  end

  it "includes the interactions from the first pact file" do
    response = Faraday.get "http://localhost:#{PORT}/path1"
    puts response.body if response.status != 200
    expect(response.status).to eq 200
  end

  it "includes the interactions from the second pact file" do
    response = Faraday.get "http://localhost:#{PORT}/path2"
    puts response.body if response.status != 200
    expect(response.status).to eq 200
  end

  after :all do
    kill_server @pid
  end
end

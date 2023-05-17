require 'support/integration_spec_support'

describe "The pact-stub-service command line interface", mri_only: true, skip_windows: true do

  include Pact::IntegrationTestSupport

  PORT = 5555

  before :all do
    clear_dirs
    @pid = start_stub_server PORT, "spec/support/pact-with-multiple-matching-interactions.json"
  end

  it "orders by response status and returns the first" do
    response = Faraday.get "http://localhost:#{PORT}/path"
    puts response.body if response.status != 200
    expect(response.status).to eq 200
  end

  after :all do
    kill_server @pid
  end
end

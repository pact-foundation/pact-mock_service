require 'fileutils'
require 'support/integration_spec_support'

describe "The pact-mock-service command line interface with a monkeypatch", mri_only: true do

  include Pact::IntegrationTestSupport

  before :all do
    clear_dirs
    @pid = start_server 3234, "--monkeypatch #{Dir.pwd}/spec/support/monkeypatch.rb"
  end

  let(:interaction) do
    {
      description: "a request with an underscored header",
      request: {
        method: :get,
        headers: {'custom_header' => 'bar'},
        path: '/greeting'
      },
      response: {
        status: 200
      }
    }.to_json
  end

  it "starts up and responds with mocked responses" do
    response = setup_interaction 3234, interaction

    `curl -H 'custom_header: bar' http://localhost:3234/greeting`

    response = verify 3234
    puts response.body unless response.status == 200
    expect(response.status).to eq 200
  end

  after :all do
    kill_server @pid
  end
end

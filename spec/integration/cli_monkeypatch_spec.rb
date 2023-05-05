require 'fileutils'
require 'support/integration_spec_support'
require 'find_a_port'

describe "The pact-mock-service command line interface with a monkeypatch", mri_only: true, skip_windows: true do

  include Pact::IntegrationTestSupport

  before :all do
    clear_dirs
    @port = FindAPort.available_port
    @pid = start_server @port, "--monkeypatch #{Dir.pwd}/spec/support/monkeypatch.rb"
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
    response = setup_interaction @port, interaction

    `curl -H 'custom_header: bar' http://localhost:#{@port}/greeting`

    response = verify @port
    puts response.body unless response.status == 200
    expect(response.status).to eq 200
  end

  after :all do
    kill_server @pid
  end
end

require 'pact/mock_service/app'
require 'rack/test'

describe Pact::Consumer::MockService do

  include Rack::Test::Methods

  let(:pact_dir) { './tmp/pacts' }
  let(:log_file) { StringIO.new }
  let(:app) { Pact::MockService.new(log_file: log_file, pact_dir: pact_dir) }

  let(:admin_headers) { {'HTTP_X_PACT_MOCK_SERVICE' => 'true', 'CONTENT_TYPE' => 'application/json'} }

  let(:alligator_interaction) do
    {
      description: "a request for alligators",
      provider_state: "alligators exist",
      request: {
        method: :get,
        path: '/alligators',
        headers: {'Accept' => 'application/alligator'}
      },
      response: {
        status: 200
      }
    }.to_json
  end

  let(:giraffe_interaction) do
    {
      description: "a request for giraffes",
      provider_state: "giraffes exist",
      request: {
        method: :get,
        path: '/giraffes',
        headers: {'Accept' => 'application/giraffe'}
      },
      response: {
        status: 200
      }
    }.to_json
  end

  let(:pact_details) do
    {
      consumer: { name: 'A Consumer'},
      provider: { name: 'A Provider'},
    }.to_json
  end

  let(:pact_file_path) { File.join(pact_dir, "a_consumer-a_provider.json") }
  let(:pact_json) { JSON.parse(File.read(pact_file_path)) }

  before do
    FileUtils.rm_rf pact_dir
    FileUtils.mkdir_p pact_dir
  end

  before do
    post "/interactions", alligator_interaction, admin_headers
    post "/interactions", giraffe_interaction, admin_headers
  end

  context "when the expected interaction is not executed" do
    it "does not include the interaction in the pact file" do
      get "/giraffes", nil, {'HTTP_ACCEPT' => 'application/giraffe'}
      get "/alligators", nil, {'HTTP_ACCEPT' => 'application/GIRAFFE'}
      post "/pact", pact_details, admin_headers
      expect(pact_json['interactions']).to_not include(
        include("description" => "a request for alligators")
      )
    end
  end

  context "when the expected interaction is executed" do
    it "includes the interaction in the pact file" do
      get "/alligators", nil, {'HTTP_ACCEPT' => 'application/alligator'}
      post "/pact", pact_details, admin_headers
      expect(pact_json['interactions']).to include(
        include("description" => "a request for alligators")
      )
    end
  end

  context "when no interactions are executed" do
    it "does not create the pact file" do
      post "/pact", pact_details, admin_headers
      expect { pact_json }.to raise_error(Errno::ENOENT)
    end
  end

end
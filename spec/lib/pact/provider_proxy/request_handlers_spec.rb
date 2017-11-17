require 'pact/provider_proxy/request_handlers'
require 'rack/test'

module Pact
  module ProviderProxy
    describe RequestHandlers do

      include Rack::Test::Methods

      class Provider
        def call(env)
          [200, {'Content-Type' => 'text/plain'}, ['Hello world']]
        end
      end

      let(:provider) { Provider.new }
      let(:logger) { Logger.new(logs) }
      let(:logs) { StringIO.new }
      let(:options) { { logger: logger, options: '2', options: 'overwrite', consumer: 'whoknows', provider: 'provider'} }
      let(:session) { Pact::MockService::Session.new(options) }

      let(:app) { Pact::ProviderProxy::RequestHandlers.new('ignore', logger, session, options, provider) }

      let(:interaction) do
        {
          description: 'a request for a greeting',
          request: {
            method: 'GET',
            path: '/'
          },
          response: {
            status: 200,
            headers: { 'Content-Type' => 'text/plain' },
            body: 'Hello world'
          }
        }
      end

      it "foo" do
        post "/interactions", interaction.to_json, {'HTTP_X_PACT_MOCK_SERVICE' => 'true'}

        puts last_response.body
        puts logs.string
      end
    end
  end
end

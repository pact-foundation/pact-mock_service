require 'pact/mock_service/request_handlers/options'

module Pact
  module MockService
    module RequestHandlers
      describe Options do
        subject {  }

        let(:logger) { Logger.new(StringIO.new) }
        let(:cors_enabled) { true }

        describe "respond" do
          let(:response) { Options.new('provider', logger, cors_enabled).respond(env) }

          describe "response headers" do
            let(:env) do
              {
                'HTTP_ORIGIN' => 'foo.com',
                'HTTP_ACCESS_CONTROL_REQUEST_HEADERS' => 'foo'
              }
            end

            subject { response[1] }

            it { is_expected.to include 'Access-Control-Allow-Methods' => 'DELETE, POST, GET, HEAD, PUT, TRACE, CONNECT, PATCH' }

            context "with Origin" do
              it { is_expected.to include 'Access-Control-Allow-Origin' => 'foo.com' }
            end

            context "with no Origin" do
              let(:env) { {} }

              it { is_expected.to include 'Access-Control-Allow-Origin' => '*' }
            end

            context "with no Access-Control-Request-Headers" do
              it { is_expected.to_not include 'Access-Control-Allow-Headers' => '*' }
            end

            context "with Access-Control-Request-Headers" do
              it { is_expected.to include 'Access-Control-Allow-Headers' => 'foo' }
            end

            context "with no Access-Control-Request-Headers" do
              let(:env) { {} }

              it { is_expected.to include 'Access-Control-Allow-Headers' => '*' }
            end
          end
        end
      end
    end
  end
end

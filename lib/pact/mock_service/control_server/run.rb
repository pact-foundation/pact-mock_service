require 'pact/mock_service/control_server/app'

module Pact
  module MockService
    module ControlServer
      class Run

        def self.call options
          new(options).call
        end

        def initialize options
          @options = options
        end

        def call
          control_server = Pact::MockService::ControlServer::App.new
          webrick_server = nil
          trap(:INT) {
            unless @shutting_down
              @shutting_down = true
              webrick_server.shutdown
            end
          }
          trap(:TERM) {
            unless @shutting_down
               @shutting_down = true
               webrick_server.shutdown
             end
          }

          # https://github.com/rack/rack/blob/master/lib/rack/handler/webrick.rb
          # Rack adapter for webrick uses class variable for the server which contains the port,
          # so if we use it more than once in the same process, we lose the reference to the first
          # server, and can't shut it down. So, keep a manual reference to the Webrick server, and
          # shut it down directly rather than use Rack::Handler::WEBrick.shutdown
          # Ruby!
          Rack::Handler::WEBrick.run(control_server, webbrick_opts) do | server |
            webrick_server = server
          end
        end

        private

        attr_reader :options

        def webbrick_opts
          {
            :Port => options[:port],
            :AccessLog => []
          }
        end

      end
    end
  end
end
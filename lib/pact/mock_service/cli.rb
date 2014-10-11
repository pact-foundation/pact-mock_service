require 'find_a_port'
require 'thor'
require 'thwait'
require 'rack/handler/webrick'

# TODO rename CLI so as not to clash

module Pact
  module MockService
    class CLI < Thor

      desc 'service', "Start a mock service"
      method_option :port, aliases: "-p", desc: "Port on which to run the service"
      method_option :log, aliases: "-l", desc: "File to which to log output"
      method_option :quiet, aliases: "-q", desc: "If true, no admin messages will be shown"

      def service
        RunStandaloneMockService.call(options)
      end

      private

      def log message
        puts message unless options[:quiet]
      end
    end

    class RunStandaloneMockService

      def self.call options
        require 'pact/consumer/mock_service/app'
        service_options = {}
        if options[:log]
          log = File.open(options[:log], 'w')
          log.sync = true
          service_options[:log_file] = log
        end

        port = options[:port] || FindAPort.available_port
        mock_service = Pact::Consumer::MockService.new(service_options)
        trap(:INT) { Rack::Handler::WEBrick.shutdown }
        Rack::Handler::WEBrick.run(mock_service, :Port => port, :AccessLog => [])
      end
    end

  end
end

require 'find_a_port'
require 'thor'
require 'thwait'
require 'webrick/https'
require 'rack/handler/webrick'

# TODO rename CLI so as not to clash

module Pact
  module MockService
    class CLI < Thor

      desc 'service', "Start a mock service"
      method_option :port, aliases: "-p", desc: "Port on which to run the service"
      method_option :ssl, desc: "Use a self-signed SSL cert to run the service over HTTPS"
      method_option :log, aliases: "-l", desc: "File to which to log output"
      method_option :quiet, aliases: "-q", desc: "If true, no admin messages will be shown"

      def service
        RunStandaloneMockService.call(options)
      end

      default_task :service

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

        mock_service = Pact::Consumer::MockService.new(service_options)
        trap(:INT) { Rack::Handler::WEBrick.shutdown }

        webbrick_opts = {
          :Port => options[:port] || FindAPort.available_port,
          :AccessLog => []
        }

        webbrick_opts.merge!({
          :SSLEnable => true,
          :SSLCertName => [ %w[CN localhost] ] }) if options[:ssl]

        Rack::Handler::WEBrick.run(mock_service, webbrick_opts)
      end
    end

  end
end

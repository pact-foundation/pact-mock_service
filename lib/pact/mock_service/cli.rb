require 'find_a_port'
require 'thor'
require 'thwait'
require 'webrick/https'
require 'rack/handler/webrick'
require 'fileutils'

module Pact
  module MockService
    class CLI < Thor

      desc 'execute', "Start a mock service"
      method_option :port, aliases: "-p", desc: "Port on which to run the service"
      method_option :ssl, desc: "Use a self-signed SSL cert to run the service over HTTPS"
      method_option :log, aliases: "-l", desc: "File to which to log output"
      method_option :pact_dir, aliases: "-d", desc: "Directory to which the pacts will be written"

      def execute
        RunStandaloneMockService.call(options)
      end

      default_task :execute

    end

    class RunStandaloneMockService

      def self.call options
        require 'pact/consumer/mock_service/app'
        service_options = {pact_dir: options[:pact_dir]}
        if options[:log]
          FileUtils.mkdir_p File.dirname(options[:log])
          log = File.open(options[:log], 'w')
          log.sync = true
          service_options[:log_file] = log
        end

        mock_service = Pact::Consumer::MockService.new(service_options)
        trap(:INT) { Rack::Handler::WEBrick.shutdown }
        trap(:TERM) { Rack::Handler::WEBrick.shutdown }

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

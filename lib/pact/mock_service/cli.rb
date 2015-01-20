require 'find_a_port'
require 'thor'
require 'thwait'
require 'webrick/https'
require 'rack/handler/webrick'
require 'fileutils'

module Pact
  module MockService
    class CLI < Thor

      desc 'execute', "Start a mock service. If the consumer, provider and pact-dir options are provided, the pact will be written automatically on shutdown."
      method_option :port, aliases: "-p", desc: "Port on which to run the service"
      method_option :ssl, desc: "Use a self-signed SSL cert to run the service over HTTPS"
      method_option :log, aliases: "-l", desc: "File to which to log output"
      method_option :cors, aliases: "-o", desc: "Support browser security in tests by responding to OPTIONS requests and adding CORS headers to mocked responses"
      method_option :pact_dir, aliases: "-d", desc: "Directory to which the pacts will be written"
      method_option :consumer, desc: "Consumer name"
      method_option :provider, desc: "Provider name"

      def execute
        RunStandaloneMockService.call(options)
      end

      default_task :execute

    end

    class RunStandaloneMockService

      def self.call options
        new(options).call
      end

      def initialize options
        @options = options
      end

      def call
        require 'pact/consumer/mock_service/app'

        trap(:INT) { call_shutdown_hooks  }
        trap(:TERM) { call_shutdown_hooks }

        Rack::Handler::WEBrick.run(mock_service, webbrick_opts)
      end

      private

      attr_reader :options

      def mock_service
        @mock_service ||= Pact::Consumer::MockService.new(service_options)
      end

      def call_shutdown_hooks
        begin
          mock_service.shutdown
        rescue StandardError => e
          $stderr.puts "Error writing pact on shutdown. #{e.class} - #{e.message}"
          $stderr.puts e.backtrace.join("\n")
        end
        Rack::Handler::WEBrick.shutdown
      end

      def service_options
        service_options = {
          pact_dir: options[:pact_dir],
          consumer: options[:consumer],
          provider: options[:provider],
          cors_enabled: options[:cors]
        }
        service_options[:log_file] = open_log_file if options[:log]
        service_options
      end

      def open_log_file
        FileUtils.mkdir_p File.dirname(options[:log])
        log = File.open(options[:log], 'w')
        log.sync = true
        log
      end

      def webbrick_opts
        opts = {
          :Port => options[:port] || FindAPort.available_port,
          :AccessLog => []
        }
        opts.merge!(ssl_opts) if options[:ssl]
        opts
      end

      def ssl_opts
        {
          :SSLEnable => true,
          :SSLCertName => [ %w[CN localhost] ]
        }
      end
    end
  end
end

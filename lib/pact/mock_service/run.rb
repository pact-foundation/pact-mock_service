require 'find_a_port'
require 'pact/mock_service/app'
require 'pact/consumer/mock_service/set_location'

module Pact
  module MockService
    class Run

      def self.call options
        new(options).call
      end

      def initialize options
        @options = options
      end

      def call
        require 'pact/mock_service/app'

        trap(:INT) { call_shutdown_hooks  }
        trap(:TERM) { call_shutdown_hooks }

        Rack::Handler::WEBrick.run(mock_service, webbrick_opts)
      end

      private

      attr_reader :options

      def mock_service
        @mock_service ||= begin
          mock_service = Pact::MockService.new(service_options)
          Pact::Consumer::SetLocation.new(mock_service, base_url)
        end
      end

      def call_shutdown_hooks
        unless @shutting_down
          @shutting_down = true
          begin
            mock_service.shutdown
          ensure
            Rack::Handler::WEBrick.shutdown
          end
        end
      end

      def service_options
        service_options = {
          pact_dir: options[:pact_dir],
          consumer: options[:consumer],
          provider: options[:provider],
          cors_enabled: options[:cors],
          pact_specification_version: options[:pact_specification_version]
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
          :Port => port,
          :Host => host,
          :AccessLog => []
        }
        opts.merge!(ssl_opts) if options[:ssl]
        opts.merge!(options[:webbrick_options]) if options[:webbrick_options]
        opts
      end

      def ssl_opts
        {
          :SSLEnable => true,
          :SSLCertName => [ %w[CN localhost] ]
        }
      end

      def port
        @port ||= options[:port] || FindAPort.available_port
      end

      def host
        @host ||= options[:host] || "localhost"
      end

      def base_url
        options[:ssl] ? "https://#{host}:#{port}" : "http://#{host}:#{port}"
      end
    end
  end
end

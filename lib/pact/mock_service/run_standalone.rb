require 'find_a_port'

module Pact
  module MockService
    class RunStandalone

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
        @mock_service ||= begin
          Pact::Consumer::MockService.new(service_options)
        end
      end

      def call_shutdown_hooks
        unless @shutting_down
          @shutting_down = true
          mock_service.shutdown
          Rack::Handler::WEBrick.shutdown
        end
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
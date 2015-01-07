require 'pact/consumer/mock_service/app'
require 'pact/consumer/server'

module Pact
  module MockService
    class Run

      def self.call consumer, provider, port, options
        new(consumer, provider, port, options).call
      end

      attr_reader :consumer, :provider, :port, :options

      def initialize consumer, provider, port, options
        @consumer = consumer
        @provider = provider
        @port = port
        @options = options
      end

      def call
        mock_service = create_mock_service
        start_mock_service mock_service, port
        puts "Started mock service for #{provider} on #{port}"
        mock_service
      end

      def create_mock_service
        name = "#{provider} mock service"
        Pact::Consumer::MockService.new(
          log_file: create_log_file(name),
          name: name,
          consumer: consumer,
          provider: provider,
          pact_dir: options[:pact_dir] || "."
        )
      end

      def start_mock_service app, port
        Pact::Server.new(app, port).boot
      end

      def create_log_file service_name
        FileUtils::mkdir_p options[:log_dir]
        log = File.open(log_file_path(service_name), 'w')
        log.sync = true
        log
      end

      def log_file_name service_name
        lower_case_name = service_name.downcase.gsub(/\s+/, '_')
        if lower_case_name.include?('_service')
          lower_case_name.gsub('_service', '_mock_service')
        else
          lower_case_name + '_mock_service'
        end
      end

      def log_file_path service_name
        File.join(options[:log_dir], "#{log_file_name(service_name)}.log")
      end
    end

  end
end

require 'securerandom'
require 'digest'
require 'socket'
require 'pact/support/metrics'
require 'pact/mock_service/version'

module Pact
  module Support
    class Metrics

      def self.report_metric(event, category, action, value = 1)
        if track_events?
          Pact.configuration.output_stream.puts "WARN: Please note: we are tracking events anonymously to gather important usage statistics like Pact-Ruby version
            and operating system. To disable tracking, set the 'PACT_DO_NOT_TRACK' environment
            variable to 'true'."

          Net::HTTP.post URI('https://www.google-analytics.com/collect'),
                         URI.encode_www_form(create_tracking_event(event, category, action, value)),
                         "Content-Type" => "application/x-www-form-urlencoded"
        end
      end

      private

      def self.create_tracking_event(event, category, action, value)
        {
          "v" => 1,
          "t" => "event",
          "tid" => "UA-117778936-1",
          "cid" => calculate_cid,
          "an" => "Pact Mock Service",
          "av" => Pact::MockService::VERSION,
          "aid" => "pact-mock_service",
          "aip" => 1,
          "ds" => ENV['PACT_EXECUTING_LANGUAGE'] ? "client" : "cli",
          "cd2" => ENV['CI'] == "true" ? "CI" : "unknown",
          "cd3" => RUBY_PLATFORM,
          "cd6" => ENV['PACT_EXECUTING_LANGUAGE'] || "unknown",
          "cd7" => ENV['PACT_EXECUTING_LANGUAGE_VERSION'],
          "el" => event,
          "ec" => category,
          "ea" => action,
          "ev" => value
        }
      end

      def self.track_events?
        ENV['PACT_DO_NOT_TRACK'] != 'true'
      end

      def self.calculate_cid
        if RUBY_PLATFORM.include? "windows"
          hostname = ENV['COMPUTERNAME']
        else
          hostname = ENV['HOSTNAME']
        end
        if !hostname
          hostname = Socket.gethostname
        end
        Digest::MD5.hexdigest hostname || SecureRandom.urlsafe_base64(5)
      end
    end
  end
end

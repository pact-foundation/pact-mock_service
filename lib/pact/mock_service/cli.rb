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
      method_option :pact_dir, aliases: "-d", desc: "Directory to which the pacts will be written"
      method_option :consumer, desc: "Consumer name"
      method_option :provider, desc: "Provider name"


      def execute
        require 'pact/mock_service/run_standalone'
        RunStandalone.call(options)
      end

      desc 'control', "Start a control server."
      method_option :port, aliases: "-p", desc: "Port on which to run the service"
      method_option :log, aliases: "-l", desc: "File to which to log output"
      method_option :pact_dir, aliases: "-d", desc: "Directory to which the pacts will be written"


      def control
        require 'pact/mock_service/control_server/run'
        Pact::MockService::ControlServer::Run.(options)
      end

      default_task :execute

    end

  end
end

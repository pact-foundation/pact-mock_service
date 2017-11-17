require 'pact/mock_service/cli/custom_thor'
require 'webrick/https'
require 'rack/handler/webrick'
require 'fileutils'
require 'pact/mock_service/server/wait_for_server_up'
require 'pact/mock_service/cli/pidfile'
require 'socket'

module Pact
  module StubService
    class CLI < Pact::MockService::CLI::CustomThor

      desc 'PROVIDER_BASE_URL ...', "Start a provider proxy service to write the given pact file(s)."

      method_option :port, aliases: "-p", desc: "Port on which to run the service"
      method_option :host, aliases: "-h", desc: "Host on which to bind the service", default: 'localhost'
      method_option :log, aliases: "-l", desc: "File to which to log output"
      method_option :monkeypatch, hide: true

      def service(*pactfiles)
        raise Thor::Error.new("Please provide an existing pact file to load") if pactfiles.empty?
        require 'pact/mock_service/run'
        options.stub_pactfile_paths = pactfiles
        opts = Thor::CoreExt::HashWithIndifferentAccess.new
        opts.merge!(options)
        opts[:stub_pactfile_paths] = pactfiles
        opts[:pactfile_write_mode] = 'none'
        MockService::Run.(opts)
      end

      desc 'version', "Show the pact-stub-service gem version"

      def version
        require 'pact/mock_service/version.rb'
        puts Pact::MockService::VERSION
      end

      default_task :service
    end
  end
end

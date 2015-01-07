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

      desc 'control', "Run a Pact mock service control server."
      method_option :port, aliases: "-p", desc: "Port on which to run the service"
      method_option :log_dir, aliases: "-l", desc: "File to which to log output"
      method_option :pact_dir, aliases: "-d", desc: "Directory to which the pacts will be written"

      def control
        require 'pact/mock_service/control_server/run'
        Pact::MockService::ControlServer::Run.(options)
      end

      desc 'start', "Start a Pact mock service control server."
      method_option :port, aliases: "-p", desc: "Port on which to run the service", default: '1234'
      method_option :log_dir, aliases: "-l", desc: "File to which to log output", default: "log"
      method_option :pact_dir, aliases: "-d", desc: "Directory to which the pacts will be written", default: "."
      method_option :pid_dir, desc: "PID dir, defaults to tmp/pids", default: "tmp/pids"

      def start
        pid = fork do
          control
        end

        sleep 1

        FileUtils.mkdir_p File.dirname(pid_path)
        File.open(pid_path, "w") { |file|  file << pid }
        Process.detach(pid)

      end

      desc 'stop', "Stop a Pact mock service control server."
      method_option :pid_dir, desc: "PID dir, defaults to tmp/pids", default: "tmp/pids"

      def stop

        if File.exist?(pid_path)
          Process.kill -2, File.read(pid_path).to_i
          sleep 1
          FileUtils.rm pid_path
        else
          $stderr.puts "PID file not found at #{pid_path}, control server probably not running."
        end

      end

      default_task :execute

      no_commands do
        def pid_path
          pid_path = File.join(options[:pid_dir], "pact-control-server.pid")
        end
      end
    end

  end
end

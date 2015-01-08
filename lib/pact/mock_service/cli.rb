require 'thor'
require 'webrick/https'
require 'rack/handler/webrick'
require 'fileutils'
require 'pact/mock_service/wait_for_server_up'
require 'pact/mock_service/cli/pidfile'
require 'socket'

module Pact
  module MockService
    class CLI < Thor

      desc 'service', "Start a mock service. If the consumer, provider and pact-dir options are provided, the pact will be written automatically on shutdown."
      method_option :port, aliases: "-p", desc: "Port on which to run the service"
      method_option :ssl, desc: "Use a self-signed SSL cert to run the service over HTTPS"
      method_option :log, aliases: "-l", desc: "File to which to log output"
      method_option :pact_dir, aliases: "-d", desc: "Directory to which the pacts will be written"
      method_option :consumer, desc: "Consumer name"
      method_option :provider, desc: "Provider name"

      def service
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

      desc 'start', "Start a mock service. If the consumer, provider and pact-dir options are provided, the pact will be written automatically on shutdown."
      method_option :port, aliases: "-p", default: '1234', desc: "Port on which to run the service"
      method_option :ssl, desc: "Use a self-signed SSL cert to run the service over HTTPS"
      method_option :log, aliases: "-l", desc: "File to which to log output"
      method_option :pact_dir, aliases: "-d", desc: "Directory to which the pacts will be written"
      method_option :consumer, desc: "Consumer name"
      method_option :provider, desc: "Provider name"
      method_option :pid_dir, desc: "PID dir", default: 'tmp/pids'

      def start
        pidfile = Pidfile.new(pid_dir: options[:pid_dir], name: mock_service_pidfile_name)

        start_server(pidfile) do
          service
        end
      end

      desc 'stop', "Stop a Pact mock service"
      method_option :port, aliases: "-p", desc: "Port of the service to stop", default: '1234', required: true
      method_option :pid_dir, desc: "PID dir, defaults to tmp/pids", default: "tmp/pids"

      def stop
        pidfile = Pidfile.new(pid_dir: options[:pid_dir], name: mock_service_pidfile_name)
        pidfile.kill_process
      end

      desc 'start-control', "Start a Pact mock service control server."
      method_option :port, aliases: "-p", desc: "Port on which to run the service", default: '1234'
      method_option :log_dir, aliases: "-l", desc: "File to which to log output", default: "log"
      method_option :pact_dir, aliases: "-d", desc: "Directory to which the pacts will be written", default: "."
      method_option :pid_dir, desc: "PID dir", default: "tmp/pids"

      def start_control
        pidfile = Pidfile.new(pid_dir: options[:pid_dir], name: control_pidfile_name)
        start_server(pidfile) do
          service
        end
      end

      desc 'stop-control', "Stop a Pact mock service control server."
      method_option :port, aliases: "-p", desc: "Port of control server to stop", default: "1234"
      method_option :pid_dir, desc: "PID dir, defaults to tmp/pids", default: "tmp/pids"

      def stop_control
        pidfile = Pidfile.new(pid_dir: options[:pid_dir], name: control_pidfile_name)
        pidfile.kill_process
      end

      default_task :service

      no_commands do

        def mock_service_pidfile_name
          "mock-service-#{options[:port]}.pid"
        end

        def control_pidfile_name
          "mock-service-control-#{options[:port]}.pid"
        end

        def port_available? port
          server = TCPServer.new('127.0.0.1', port)
          true
        rescue
          false
        ensure
          server.close if server
        end

        def start_server pidfile
          if port_available? options[:port]
            if pidfile.can_start?
              pid = fork do
                yield
              end
              pidfile.pid = pid
              Process.detach(pid)
              WaitForServerUp.(options[:port])
              pidfile.write
            end
          else
            puts "ERROR: Port #{options[:port]} already in use."
            exit 1
          end
        end
      end
    end

  end
end

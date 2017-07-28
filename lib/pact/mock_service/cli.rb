require 'thor'
require 'webrick/https'
require 'rack/handler/webrick'
require 'fileutils'
require 'pact/mock_service/server/wait_for_server_up'
require 'pact/mock_service/cli/pidfile'
require 'socket'
require 'rake/file_utils'

module Pact
  module MockService
    class CLI < Thor

      desc 'service', "Start a mock service. If the consumer, provider and pact-dir options are provided, the pact will be written automatically on shutdown."
      method_option :port, aliases: "-p", desc: "Port on which to run the service"
      method_option :host, aliases: "-h", desc: "Host on which to bind the service", default: 'localhost'
      method_option :log, aliases: "-l", desc: "File to which to log output"
      method_option :ssl, desc: "Use a self-signed SSL cert to run the service over HTTPS", type: :boolean, default: false
      method_option :sslcert, desc: "Specify the path to the SSL cert to use when running the service over HTTPS"
      method_option :sslkey, desc: "Specify the path to the SSL key to use when running the service over HTTPS"
      method_option :cors, aliases: "-o", desc: "Support browser security in tests by responding to OPTIONS requests and adding CORS headers to mocked responses"
      method_option :pact_dir, aliases: "-d", desc: "Directory to which the pacts will be written"
      method_option :pact_specification_version, aliases: "-i", desc: "The pact specification version to use when writing the pact", default: '1'
      method_option :consumer, desc: "Consumer name"
      method_option :provider, desc: "Provider name"

      def service
        require 'pact/mock_service/run'
        Run.(options)
      end

      desc 'control', "Run a Pact mock service control server."
      method_option :port, aliases: "-p", desc: "Port on which to run the service"
      method_option :host, aliases: "-h", desc: "Host on which to bind the service", default: 'localhost'
      method_option :log_dir, aliases: "-l", desc: "File to which to log output"
      method_option :pact_dir, aliases: "-d", desc: "Directory to which the pacts will be written"
      method_option :pact_specification_version, aliases: "-i", desc: "The pact specification version to use when writing the pact", default: '1'
      method_option :ssl, desc: "Use a self-signed SSL cert to run the service over HTTPS", type: :boolean, default: false
      method_option :sslcert, desc: "Specify the path to the SSL cert to use when running the service over HTTPS"
      method_option :sslkey, desc: "Specify the path to the SSL key to use when running the service over HTTPS"
      method_option :cors, aliases: "-o", desc: "Support browser security in tests by responding to OPTIONS requests and adding CORS headers to mocked responses"

      def control
        require 'pact/mock_service/control_server/run'
        ControlServer::Run.(options)
      end

      desc 'start', "Start a mock service. If the consumer, provider and pact-dir options are provided, the pact will be written automatically on shutdown."
      method_option :port, aliases: "-p", default: '1234', desc: "Port on which to run the service"
      method_option :host, aliases: "-h", desc: "Host on which to bind the service", default: 'localhost'
      method_option :log, aliases: "-l", desc: "File to which to log output"
      method_option :ssl, desc: "Use a self-signed SSL cert to run the service over HTTPS", type: :boolean, default: false
      method_option :sslcert, desc: "Specify the path to the SSL cert to use when running the service over HTTPS"
      method_option :sslkey, desc: "Specify the path to the SSL key to use when running the service over HTTPS"
      method_option :cors, aliases: "-o", desc: "Support browser security in tests by responding to OPTIONS requests and adding CORS headers to mocked responses"
      method_option :pact_dir, aliases: "-d", desc: "Directory to which the pacts will be written"
      method_option :pact_specification_version, aliases: "-i", desc: "The pact specification version to use when writing the pact", default: '1'
      method_option :consumer, desc: "Consumer name"
      method_option :provider, desc: "Provider name"
      method_option :pid_dir, desc: "PID dir", default: 'tmp/pids'

      def start
        spawn_mock_service
      end

      desc 'stop', "Stop a Pact mock service"
      method_option :port, aliases: "-p", desc: "Port of the service to stop", default: '1234', required: true
      method_option :pid_dir, desc: "PID dir, defaults to tmp/pids", default: "tmp/pids"

      def stop
        mock_service_pidfile.kill_process
      end

      desc 'restart', "Start or restart a mock service. If the consumer, provider and pact-dir options are provided, the pact will be written automatically on shutdown."
      method_option :port, aliases: "-p", default: '1234', desc: "Port on which to run the service"
      method_option :host, aliases: "-h", desc: "Host on which to bind the service", default: 'localhost'
      method_option :log, aliases: "-l", desc: "File to which to log output"
      method_option :ssl, desc: "Use a self-signed SSL cert to run the service over HTTPS", type: :boolean, default: false
      method_option :sslcert, desc: "Specify the path to the SSL cert to use when running the service over HTTPS"
      method_option :sslkey, desc: "Specify the path to the SSL key to use when running the service over HTTPS"
      method_option :cors, aliases: "-o", desc: "Support browser security in tests by responding to OPTIONS requests and adding CORS headers to mocked responses"
      method_option :pact_dir, aliases: "-d", desc: "Directory to which the pacts will be written"
      method_option :pact_specification_version, aliases: "-i", desc: "The pact specification version to use when writing the pact", default: '1'
      method_option :consumer, desc: "Consumer name"
      method_option :provider, desc: "Provider name"
      method_option :pid_dir, desc: "PID dir", default: 'tmp/pids'

      def restart
        restart_server(mock_service_pidfile) do
          service
        end
      end

      desc 'control-start', "Start a Pact mock service control server."
      method_option :port, aliases: "-p", desc: "Port on which to run the service", default: '1234'
      method_option :log_dir, aliases: "-l", desc: "File to which to log output", default: "log"
      method_option :ssl, desc: "Use a self-signed SSL cert to run the service over HTTPS", type: :boolean, default: false
      method_option :sslcert, desc: "Specify the path to the SSL cert to use when running the service over HTTPS"
      method_option :sslkey, desc: "Specify the path to the SSL key to use when running the service over HTTPS"
      method_option :cors, aliases: "-o", desc: "Support browser security in tests by responding to OPTIONS requests and adding CORS headers to mocked responses"
      method_option :pact_dir, aliases: "-d", desc: "Directory to which the pacts will be written", default: "."
      method_option :pact_specification_version, aliases: "-i", desc: "The pact specification version to use when writing the pact", default: '1'
      method_option :pid_dir, desc: "PID dir", default: "tmp/pids"

      def control_start
        start_server(control_server_pidfile) do
          control
        end
      end

      desc 'control-stop', "Stop a Pact mock service control server."
      method_option :port, aliases: "-p", desc: "Port of control server to stop", default: "1234"
      method_option :pid_dir, desc: "PID dir, defaults to tmp/pids", default: "tmp/pids"

      def control_stop
        control_server_pidfile.kill_process
      end

      desc 'control-restart', "Start a Pact mock service control server."
      method_option :port, aliases: "-p", desc: "Port on which to run the service", default: '1234'
      method_option :log_dir, aliases: "-l", desc: "File to which to log output", default: "log"
      method_option :ssl, desc: "Use a self-signed SSL cert to run the service over HTTPS", type: :boolean, default: false
      method_option :sslcert, desc: "Specify the path to the SSL cert to use when running the service over HTTPS"
      method_option :sslkey, desc: "Specify the path to the SSL key to use when running the service over HTTPS"
      method_option :cors, aliases: "-o", desc: "Support browser security in tests by responding to OPTIONS requests and adding CORS headers to mocked responses"
      method_option :pact_dir, aliases: "-d", desc: "Directory to which the pacts will be written", default: "."
      method_option :pact_specification_version, aliases: "-i", desc: "The pact specification version to use when writing the pact", default: '1'
      method_option :pid_dir, desc: "PID dir", default: "tmp/pids"

      def control_restart
        restart_server(control_server_pidfile) do
          control
        end
      end

      desc 'version', "Show the pact-mock-service gem version"

      def version
        require 'pact/mock_service/version.rb'
        puts Pact::MockService::VERSION
      end

      default_task :service

      no_commands do

        def control_server_pidfile
          Pidfile.new(pid_dir: options[:pid_dir], name: control_pidfile_name)
        end

        def mock_service_pidfile
          Pidfile.new(pid_dir: options[:pid_dir], name: mock_service_pidfile_name)
        end

        def mock_service_pidfile_name
          "mock-service-#{options[:port]}.pid"
        end

        def control_pidfile_name
          "mock-service-control-#{options[:port]}.pid"
        end

        def start_server pidfile
          require 'pact/mock_service/server/spawn'
          Pact::MockService::Server::Spawn.(pidfile, options[:port], options[:ssl]) do
            yield
          end
        end

        def restart_server pidfile
          require 'pact/mock_service/server/respawn'
          Pact::MockService::Server::Respawn.(pidfile, options[:port], options[:ssl]) do
            yield
          end
        end

        def spawn_mock_service
          pidfile = mock_service_pidfile
          if pidfile.can_start?
            if port_available? options.port
              pid = spawn(service_spawn_command, {new_pgroup: true})
              pidfile.pid = pid
              Process.detach(pid)
              Pact::MockService::Server::WaitForServerUp.(options.port, {ssl: options.ssl})
              pidfile.write
            else
              raise PortUnavailableError.new("ERROR: Port #{options.port} already in use.")
            end
          end
        end

        def service_spawn_command
          command = []
          command << FileUtils::RUBY
          command << "-S #{$0} service"
          command += build_service_options
          command.join(" ")
        end

        def service_switch_names
          Pact::MockService::CLI.commands['service'].options.values.each_with_object({}){| option, hash| hash[option.human_name] = option.switch_name }
        end

        def build_service_options
          switch_names = service_switch_names
          options.collect{ |key, value| "#{switch_names[key]} #{value}" if switch_names[key] }.compact
        end

        def port_available? port
          server = TCPServer.new('127.0.0.1', port)
          true
        rescue
          false
        ensure
          server.close if server
        end
      end
    end
  end
end

require 'find_a_port'
require 'thor'
require 'thwait'
require 'webrick/https'
require 'rack/handler/webrick'
require 'fileutils'
require 'pact/mock_service/wait_for_server_up'
require 'pidfile'

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

        pidfile = PidFile.new(:pidfile => "pact-control-server.pid")
        if pidfile

        if port_available? options[:port]

          pid = fork do

            control
          end
          Process.detach(pid)
          FileUtils.mkdir_p File.dirname(pid_path)
          WaitForServerUp.(options[:port])
          File.open(pid_path, "w") { |file|  file << pid }
        else
          puts "ERROR: Port #{options[:port]} already in use."
          exit 1
        end
      end

      desc 'stop', "Stop a Pact mock service control server."
      method_option :pid_dir, desc: "PID dir, defaults to tmp/pids", default: "tmp/pids"

      def stop
        if pidfile_exists?
          Process.kill 2, pid_from_pidfile
          sleep 1
          FileUtils.rm pid_path
        else
          $stderr.puts "No PID file found at #{pid_path}, control server probably not running."
        end
      end

      default_task :execute

      no_commands do

        def port_available? port
          server = TCPServer.new('127.0.0.1', port)
          true
        rescue
          false
        ensure
          server.close if server
        end

        def process_exists? pid
          Process.kill 0, pid
          true
        rescue  Errno::ESRCH
          false
        end

        def pid_from_pidfile
          File.read(pid_path).to_i
        end

        def pid_path
          pid_path = File.join(options[:pid_dir], "pact-control-server.pid")
        end

        def pidfile_exists?
          File.exist?(pid_path)
        end
      end
    end

  end
end

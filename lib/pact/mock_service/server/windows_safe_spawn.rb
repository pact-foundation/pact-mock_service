require 'pact/mock_service/server/wait_for_server_up'
require 'pact/mock_service/os'

module Pact
  module MockService
    module Server
      class WindowsSafeSpawn

        class PortUnavailableError < StandardError; end

        def self.call command, pidfile, port, ssl = false
          if pidfile.can_start?
            if port_available? port
              pid = spawn(command, spawn_options)
              pidfile.pid = pid
              Process.detach(pid)
              Server::WaitForServerUp.(port, {ssl: ssl})
              pidfile.write
            else
              raise PortUnavailableError.new("ERROR: Port #{port} already in use.")
            end
          end
        end

        def self.spawn_options
          if Pact::MockService::OS.windows?
            {new_pgroup: true}
          else
            {}
          end
        end

        def self.port_available? port
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

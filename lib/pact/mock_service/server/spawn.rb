require 'pact/mock_service/server/wait_for_server_up'

module Pact
  module MockService
    module Server
      class Spawn

        class PortUnavailableError < StandardError; end

        def self.call pidfile, port, ssl = false
          if pidfile.can_start?
            if port_available? port
              pid = fork do
                yield
              end
              pidfile.pid = pid
              Process.detach(pid)
              Server::WaitForServerUp.(port, {ssl: ssl})
              pidfile.write
            else
              raise PortUnavailableError.new("ERROR: Port #{port} already in use.")
            end
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

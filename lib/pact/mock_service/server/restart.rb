require 'pact/mock_service/server/spawn'

module Pact
  module MockService
    module Server
      class Respawn

        def self.call pidfile, port
          if pidfile.file_exists_and_process_running?
            pidfile.kill_process
          end

          Spawn.(pidfile, port) do
            yield
          end
        end
      end
    end
  end
end

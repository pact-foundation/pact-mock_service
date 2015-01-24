require 'timeout'
require 'net/http'

module Pact
  module MockService
    module Server
      class WaitForServerUp

        def self.call(port, options = {ssl: false})
          tries = 0
          responsive = false
          while !(responsive = responsive?(port, options)) && tries < 100
            tries += 1
            sleep 1
          end
          raise "Timed out waiting for server to start up on port #{port}" if !responsive
        end

        def self.responsive? port, options
          res = Net::HTTP.start("localhost", port) do |http|
            request = Net::HTTP::Get.new "http://localhost:#{port}/"
            request['X-Pact-Mock-Service'] = 'true'
            response = http.request request
          end
          res.code == '200'
        rescue SystemCallError => e
          return false
        rescue EOFError
          return false
        end
      end

    end
  end
end

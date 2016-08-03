require 'timeout'
require 'net/http'
require 'openssl'

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
          http = Net::HTTP.new('localhost', port)
          if options[:ssl]
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            scheme = 'https'
          else
            scheme = 'http'
          end
          http.start {
            request = Net::HTTP::Get.new "#{scheme}://localhost:#{port}/"
            request['X-Pact-Mock-Service'] = true
            response = http.request request
            response.code == '200'
          }
        rescue SystemCallError => e
          return false
        rescue EOFError
          return false
        end
      end

    end
  end
end

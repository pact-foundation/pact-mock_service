require 'timeout'
require 'net/http'

module Pact
  module MockService
    class WaitForServerUp

      def self.call(port, options = {ssl: false})
        tries = 0
        while !responsive?(port, options) && tries < 100
          tries += 1
          sleep 1
        end

      end

      def self.responsive? port, options
        res = Net::HTTP.start("localhost", port) do |http|
          http.get('/')
        end

        puts res

        true
      rescue SystemCallError => e
        puts e
        return false
      rescue EOFError
        puts EOFError
        return false
      end
    end
  end
end

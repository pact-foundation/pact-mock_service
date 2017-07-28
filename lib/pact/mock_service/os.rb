module Pact
  module MockService
    module OS

      extend self

      # Thanks RSpec
      def windows?
        !!(RbConfig::CONFIG['host_os'] =~ /cygwin|mswin|mingw|bccwin|wince|emx/)
      end
    end
  end
end

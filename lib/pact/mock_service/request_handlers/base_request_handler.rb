require 'pact/consumer/mock_service/rack_request_helper'

module Pact
  module MockService
    module RequestHandlers
      class BaseRequestHandler

        NOT_FOUND_RESPONSE = [404, {}, []].freeze

        include Pact::Consumer::RackRequestHelper

        def match? env
          raise NotImplementedError
        end

        def call env
          match?(env) ? respond(env) : NOT_FOUND_RESPONSE
        end
      end
    end
  end
end
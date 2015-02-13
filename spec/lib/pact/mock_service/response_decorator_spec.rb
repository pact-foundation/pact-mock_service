require 'pact/mock_service/response_decorator'
require 'support/shared_examples_for_response_decorator'

module Pact
  module MockService
    describe ResponseDecorator do

      include_examples "response decorator to_json"

    end
  end
end

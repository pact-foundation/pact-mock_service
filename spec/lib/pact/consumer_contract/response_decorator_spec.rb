require 'pact/consumer_contract/response_decorator'
require 'support/shared_examples_for_response_decorator'

module Pact
  describe ResponseDecorator do

    include_examples "request decorator to_json"

  end
end

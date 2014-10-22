require 'pact/shared/active_support_support'
require 'pact/consumer_contract/request_decorator'
require 'pact/consumer_contract/response_decorator'

module Pact
  class InteractionDecorator

    include ActiveSupportSupport

    def initialize interaction
      @interaction = interaction
    end

    def as_json options = {}
      fix_all_the_things to_hash
    end

    def to_json(options = {})
      as_json.to_json(options)
    end

    def to_hash
      hash = { :description => interaction.description }
      hash[:provider_state] = interaction.provider_state if interaction.provider_state
      hash[:request] = decorate_request.as_json
      hash[:response] = decorate_response.as_json
      hash
    end

    private

    attr_reader :interaction

    def decorate_request
      RequestDecorator.new(interaction.request)
    end

    def decorate_response
      ResponseDecorator.new(interaction.response)
    end

  end
end

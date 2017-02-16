require 'pact/reification'

module Pact
  class RequestDecorator

    def initialize request, decorator_options = {}
      @request = request
      @decorator_options = decorator_options
    end

    def to_json(options = {})
      as_json.to_json(options)
    end

    def as_json options = {}
      hash = {
        method: request.method,
        path: request.path
      }
      hash[:query]   = request.query   if request.specified?(:query)
      hash[:headers] = request.headers if request.specified?(:headers)
      hash[:body]    = body    if request.specified?(:body)
      include_matching_rules? ? with_matching_rules(hash) : hash
    end

    private

    attr_reader :request

    # This feels wrong to be checking the class type of the body
    # Do this better somehow.
    def body
      if content_type_is_form && request.body.is_a?(Hash)
        URI.encode_www_form convert_hash_body_to_array_of_arrays
      else
        request.body
      end
    end

    def content_type_is_form
      request.content_type? 'application/x-www-form-urlencoded'
    end

    #This probably belongs somewhere else.
    def convert_hash_body_to_array_of_arrays
      arrays = []
      request.body.keys.each do | key |
        [*request.body[key]].each do | value |
          arrays << [key, value]
        end
      end
      arrays
    end

    def include_matching_rules?
      pact_specification_version && !pact_specification_version.start_with?('1')
    end

    def with_matching_rules hash
      matching_rules = Pact::MatchingRules.extract hash
      example = Pact::Reification.from_term hash
      return example if matching_rules.empty?
      example.merge(matchingRules: matching_rules)
    end

    def pact_specification_version
      @decorator_options[:pact_specification_version]
    end

  end
end
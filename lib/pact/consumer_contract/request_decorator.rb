require 'pact/reification'

module Pact
  class RequestDecorator

    def initialize request
      @request = request
    end

    def to_json(options = {})
      as_json.to_json(options)
    end

    def as_json options = {}
      to_hash
    end

    def to_hash
      hash = {
        method: request.method,
        path: request.path,
      }
      hash[:query]   = query           if request.specified?(:query)
      hash[:headers] = request.headers if request.specified?(:headers)
      hash[:body]    = body            if request.specified?(:body)
      hash
    end

    private

    attr_reader :request

    # This feels wrong to be checking the class type of the Query
    # Do this better somehow.
    def query
      if request.query.is_a?(Pact::QueryHash)
        Pact::Reification.from_term(request.query)
      else
        request.query
      end
    end

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
      request.content_type == 'application/x-www-form-urlencoded'
    end

    #This probably belongs somewhere else.
    def convert_hash_body_to_array_of_arrays
      arrays = []
      request.body.keys.each do | key |
        [*request.body[key]].each do | value |
          arrays << [key, Pact::Reification.from_term(value)]
        end
      end
      arrays
    end

  end
end

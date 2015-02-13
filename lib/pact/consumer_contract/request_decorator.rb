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
        path: path
      }
      hash[:query]   = query   if request.specified?(:query)
      hash[:headers] = headers if request.specified?(:headers)
      hash[:body]    = body    if request.specified?(:body)
      hash
    end

    private

    attr_reader :request

    def path
      Pact::Reification.from_term(request.path)
    end

    def headers
      Pact::Reification.from_term(request.headers)
    end

    # This feels wrong to be checking the class type of the Query
    # Do this better somehow.
    def query
      Pact::Reification.from_term(request.query)
    end

    # This feels wrong to be checking the class type of the body
    # Do this better somehow.
    def body
      if content_type_is_form && request.body.is_a?(Hash)
        URI.encode_www_form convert_hash_body_to_array_of_arrays
      else
        Pact::Reification.from_term(request.body)
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
      Pact::Reification.from_term arrays
    end

  end
end

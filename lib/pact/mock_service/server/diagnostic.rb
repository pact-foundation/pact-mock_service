module Pact
  module MockService
    module Server
      class Diagnostic
        attr_accessor :error

        def initialize(app)
          @app = app
        end

        def call(env)
          if env["PATH_INFO"] == "/__identify__" && env['HTTP_X_PACT_MOCK_SERVICE']
            [200, {}, [@app.object_id.to_s]]
          else
            begin
              @app.call(env)
            rescue StandardError => e
              @error = e unless @error
              raise e
            end
          end
        end

        def shutdown
          @app.shutdown
        end
      end
    end
  end
end

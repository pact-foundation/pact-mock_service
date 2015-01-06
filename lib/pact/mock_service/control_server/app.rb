require 'pact/consumer/app_manager'

module Pact
  module MockService
    module ControlServer
      class App
        def call env
          puts env
          Pact::Consumer::AppManager.instance.register_mock_service_for 'bethtest', 'http://localhost:1234'
          Pact::Consumer::AppManager.instance.spawn_all
          [200, {}, []]
        end
      end
    end
  end
end

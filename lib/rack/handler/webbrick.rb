module Rack
  module Handler
      begin
        require 'rack/handler/webrick'
        WEBrick = Class.new(Rack::Handler::WEBrick)
      rescue LoadError
        require 'rackup/handler/webrick'
        WEBrick = Class.new(Rackup::Handler::WEBrick)
      end
  end
end


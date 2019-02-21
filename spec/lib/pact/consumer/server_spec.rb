require 'pact/consumer/server'

describe Pact::Server do
  describe 'booting' do
    context 'with `nil` port' do
      let(:app) { -> (env) { [200, {}, ['OK']] } }
      let(:server) { described_class.new(app, 'localhost', nil) }

      it 'boots server with port 0 trick' do
        expect(server.port).to be_nil
        Timeout.timeout(10) { server.boot } # Raise when something failed and waits for that
        expect(server.port).to be_a(Integer)
        expect(server.port).to be > 0
      end
    end
  end
end

require 'pact/consumer/server'

describe Pact::Server do
  describe 'booting' do
    context 'with `nil` port' do
      let(:app) { double(:app) }
      let(:webrick_server) { { Port: 1234 } }
      let(:server) { described_class.new(app, nil) }
      before { allow(server).to receive(:responsive?).and_return(false, true) }

      it 'boots server with port 0 trick' do
        expect(Rack::Handler::WEBrick).to receive(:run).
          with(anything, hash_including(Port: 0)).
          and_yield(webrick_server)

        expect(server.port).to be_nil
        Timeout.timeout(3) { server.boot } # Raise when something failed and waits for that
        expect(server.port).to eq(1234)
      end
    end
  end
end

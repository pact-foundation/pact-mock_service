require 'pact/mock_service/app_manager'

module Pact::MockService
  describe AppManager do
    before do
      AppManager.instance.clear_all
    end

    describe "register_mock_service_for" do
      before do
        allow_any_instance_of(AppRegistration).to receive(:spawn) # Don't want process actually spawning during the tests
      end

      let(:name) { 'some_service'}
      let(:options) { { pact_specification_version: '3' } }

      context "for http://localhost" do
        let(:url) { 'http://localhost:1234'}

        it "starts a mock service at the given port on localhost" do
          expect_any_instance_of(AppRegistration).to receive(:spawn)
          AppManager.instance.register_mock_service_for name, url, options
          AppManager.instance.spawn_all
        end

        it "registers the mock service as running on the given port" do
          AppManager.instance.register_mock_service_for name, url, options
          expect(AppManager.instance.app_registered_on?(1234)).to eq true
        end

        it "creates a mock service with the configured pact_dir" do
          allow(Pact.configuration).to receive(:pact_dir).and_return('pact_dir')
          expect(Pact::MockService).to receive(:new) do | options |
            expect(options[:pact_dir]).to eq 'pact_dir'
          end
          AppManager.instance.register_mock_service_for name, url, options
        end

        it "passes in the pact_specification_verson to the MockService" do
          expect(Pact::MockService).to receive(:new).with(hash_including(pact_specification_version: '3')).and_call_original
          AppManager.instance.register_mock_service_for name, url, options
        end
      end

      context "for https://" do
        let(:url) { 'https://localhost:1234'}

        it "should throw an unsupported error" do
          expect { AppManager.instance.register_mock_service_for name, url, options }.to raise_error "Currently only http is supported"
        end
      end

      describe "find_a_port option" do
        let(:url) { 'http://localhost' }

        before do
          options[:find_available_port] = true
        end

        it "builds AppRegistration with `nil` port" do
          expect(AppRegistration).to receive(:new).with(hash_including(port: nil)).and_call_original
          AppManager.instance.register_mock_service_for name, url, options
        end
      end
    end
  end
end

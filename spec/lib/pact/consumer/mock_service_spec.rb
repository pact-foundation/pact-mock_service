require 'spec_helper'
require 'rack/test'
require 'tempfile'
require 'pact/consumer/mock_service'

module Pact
  module Consumer

    describe MockService do

      include Rack::Test::Methods

      def app
        MockService.new(log_file: temp_file)
      end

      let(:temp_file) { Tempfile.new('log') }

      after do
        temp_file.close
        temp_file.unlink
      end

      let(:response) { JSON.parse(last_response.body)}
      let(:interaction_replay) { double(InteractionReplay, :match? => true)}

      subject { get "/" }

      before do
        allow(Pact::MockService::RequestHandlers::InteractionReplay).to receive(:new).and_return(interaction_replay)
      end

      context "when a StandardError is encountered" do
        let(:response) { JSON.parse(last_response.body)}
        let(:interaction_replay) { double(Pact::MockService::RequestHandlers::InteractionReplay, :match? => true)}

        before do
          expect(interaction_replay).to receive(:respond).and_raise("an error")
        end

        subject { get "/" }

        it "returns a json error" do
          subject
          expect(last_response.content_type).to eq 'application/json'
        end

        it "includes the error message" do
          subject
          expect(response['message']).to include "RuntimeError - an error"
        end

        it "includes the backtrace" do
          subject
          expect(response['backtrace']).to be_instance_of Array
        end
      end

    end
  end
end

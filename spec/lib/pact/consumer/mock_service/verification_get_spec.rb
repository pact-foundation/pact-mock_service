require 'pact/mock_service/request_handlers/verification_get'
require 'pact/mock_service/interactions/verification'
require 'pact/mock_service/interactions/expected_interactions'
require 'pact/mock_service/interactions/actual_interactions'

module Pact
  module MockService
    module RequestHandlers
      describe VerificationGet do

        let(:expected_interactions) { instance_double("Pact::MockService::Interactions::ExpectedInteractions") }
        let(:actual_interactions) { instance_double("Pact::MockService::Interactions::ActualInteractions") }
        let(:verification) { instance_double("Pact::Consumer::Verification") }
        let(:session) { instance_double("Pact::MockService::Session", expected_interactions: expected_interactions, actual_interactions: actual_interactions) }
        let(:logger) { double("Logger", description: log_description).as_null_object }
        let(:log_description) { "/log/pact.log" }

        before do
          allow(Pact::MockService::Interactions::Verification).to receive(:new).and_return(verification)
        end

        subject { VerificationGet.new('VerificationGet', logger, session) }

        describe "request_path" do
          it "is /interactions/verification" do
            expect(subject.request_path).to eq '/interactions/verification'
          end
        end

        describe "request_method" do
          it "is GET" do
            expect(subject.request_method).to eq 'GET'
          end
        end

        describe "#respond" do
          let(:env) { {
            "QUERY_STRING" => "example_description=a description"
          } }

          before do
            allow(verification).to receive(:all_matched?).and_return(all_matched)
          end

          let(:response) { subject.respond env }

          context "when all interactions have been matched" do
            let(:all_matched) { true }

            it "returns a 200 status" do
              expect(response.first).to eq 200
            end

            it "returns a Content-Type of text/plain" do
              expect(response[1]).to eq 'Content-Type' => 'text/plain'
            end

            it "returns a nice message" do
              expect(response.last).to eq ["Interactions matched\n"]
            end

            it "logs the success" do
              expect(logger).to receive(:info).with(/Verifying - interactions matched.*a description/)
              response
            end
          end

          context "when all interactions not been matched" do
            let(:all_matched) { false }
            let(:failure_message) { "this is a failure message"}

            before do
              allow_any_instance_of(VerificationGet::FailureMessage).to receive(:to_s).and_return(failure_message)
            end

            it "returns a 500 status" do
              expect(response.first).to eq 500
            end

            it "returns a Content-Type of text/plain" do
              expect(response[1]).to eq 'Content-Type' => 'text/plain'
            end

            it "creates a failure message" do
              expect(VerificationGet::FailureMessage).to receive(:new).with(verification)
              response
            end

            it "returns a message" do
              expect(response.last.first).to include "Actual interactions do not match"
              expect(response.last.first).to include failure_message
              expect(response.last.first).to include log_description
            end

            it "logs the failure message" do
              expect(logger).to receive(:warn).with(/Verifying - actual interactions do not match/)
              expect(logger).to receive(:warn).with(failure_message)
              response
            end

          end

        end

        describe "FailureMessage" do
          let(:missing_interactions_summaries) { ["Blah", "Thing"]}
          let(:interaction_mismatches_summaries) { []}
          let(:unexpected_requests_summaries) { []}
          let(:verification) { instance_double("Pact::Consumer::Verification") }
          subject { VerificationGet::FailureMessage.new(verification).to_s }

          before do
            allow(verification).to receive(:missing_interactions_summaries).and_return(missing_interactions_summaries)
            allow(verification).to receive(:interaction_mismatches_summaries).and_return(interaction_mismatches_summaries)
            allow(verification).to receive(:unexpected_requests_summaries).and_return(unexpected_requests_summaries)
          end

          context "with only a missing interactions" do

            let(:expected_string) { <<-EOS
Missing requests:
\tBlah
\tThing

EOS
}
            it "only includes missing interactions" do
              expect(subject).to eq expected_string
            end
          end

          context "with missing, mismatches and unexpected interactions" do

            let(:interaction_mismatches_summaries) { ["wiffle"]}
            let(:unexpected_requests_summaries) { ["moose"]}

            let(:expected_string) { <<-EOS
Incorrect requests:
\twiffle

Missing requests:
\tBlah
\tThing

Unexpected requests:
\tmoose

EOS
}
            it "includes all the things" do
              expect(subject).to eq expected_string
            end
          end
        end
      end
    end
  end
end
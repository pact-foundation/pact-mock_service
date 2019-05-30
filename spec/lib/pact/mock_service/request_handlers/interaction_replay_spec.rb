require 'spec_helper'
require 'pact/mock_service/request_handlers/interaction_replay'
require 'pact/mock_service/interactions/expected_interactions'
require 'pact/mock_service/interactions/actual_interactions'

module Pact
  module MockService
    module RequestHandlers

      describe InteractionReplay do

        let(:expected_interaction) do
          Interaction.from_hash(
            'description' => 'a request',
            'request' => { 'method' => 'get', 'path' => '/path', 'body' => {'a' => 'body'} },
            'response' => { 'status' => 200, 'headers' => {'some' => 'headers'}, 'body' => {'response' => 'body'} }
          )
        end
        let(:logger) { Logger.new(StringIO.new) }
        let(:expected_interactions) { Pact::MockService::Interactions::ExpectedInteractions.new }
        let(:actual_interactions) { Pact::MockService::Interactions::ActualInteractions.new }
        let(:verified_interactions) { [] }
        let(:session) do
          instance_double("Pact::MockService::Session",
            expected_interactions: expected_interactions,
            actual_interactions: actual_interactions,
            verified_interactions: verified_interactions)
        end

        let(:actual_body) { {'a' => 'body' } }

        before do
          expected_interactions << expected_interaction
        end

        subject { InteractionReplay.new('provider', logger, session, false, stub) }
        let(:response) { subject.respond env }
        let(:response_body) { JSON.parse(response[2][0]) }
        let(:response_status) { response[0] }
        let(:response_headers) { response[1] }
        let(:stub) { false }

        context "when at least one request with a matching method and path is found" do
          let(:env) do
            {
              'REQUEST_METHOD' => 'GET',
              'PATH_INFO' => '/path',
              'QUERY_STRING' => '',
              'rack.input' => double(read: actual_body)
            }
          end

          context "when a full match is found" do
            it "returns the specified response status" do
              expect(response_status).to eq 200
            end

            it "returns the specified response headers" do
              expect(response_headers).to eq 'some' => 'headers'
            end

            it "returns the specified response body" do
              expect(response_body).to eq 'response' => 'body'
            end

            it "adds the interaction to the verified interactions list" do
              response
              expect(verified_interactions.size).to eq 1
            end
          end

          context "when a full match is not found" do

            let(:actual_body) { {'a' => 'different body' } }

            let(:expected_response_body) do
              {"message"=>"No interaction found for GET /path", "interaction_diffs"=>[{"description"=>"a request", "body"=>{"a"=>{"EXPECTED"=>"body", "ACTUAL"=>"different body"}}}]}
            end

            it "returns an 500 error status" do
              expect(response_status).to eq 500
            end

            it "returns a json body" do
              expect(response_headers).to eq "Content-Type"=>"application/json"
            end

            it "returns a list of diffs" do
              expect(response_body).to eq(expected_response_body)
            end

            it "does not add the interaction to the verified interactions list" do
              response
              expect(verified_interactions.size).to eq 0
            end
          end

          context "when more than one matching request is found" do
            context "when not in stub mode" do
              before do
                expected_interactions << expected_interaction
              end

              let(:expected_response_body) do
                {"message"=>"Multiple interaction found for GET /path", "matching_interactions"=>[{"description"=>"a request", "request"=>{"method"=>"get", "path"=>"/path", "body"=>{"a"=>"body"}}}, {"description"=>"a request", "request"=>{"method"=>"get", "path"=>"/path", "body"=>{"a"=>"body"}}}]}
              end

              it "returns an 500 error status" do
                expect(response_status).to eq 500
              end

              it "returns a json body" do
                expect(response_headers).to eq "Content-Type"=>"application/json"
              end

              it "returns a diff for each candidate interaction" do
                expect(response_body).to eq expected_response_body
              end

              it "does not add the interaction to the verified interactions list" do
                response
                expect(verified_interactions.size).to eq 0
              end
            end

            context "when in stub mode" do
              before do
                expected_interactions << another_interaction
              end

              let(:another_interaction) do
                Interaction.from_hash(
                  'description' => 'a request',
                  'request' => { 'method' => 'get', 'path' => '/path', 'body' => {'a' => 'body'} },
                  'response' => { 'status' => 400, 'headers' => {'some' => 'headers'}, 'body' => {'response' => 'body'} }
                )
              end

              let(:stub) { true }

              it "orders by status and returns the first one" do
                expect(response_status).to eq 200
              end
            end
          end
          
          context "when the body contains special charachters" do
            let(:actual_body) { '\xEB' }
            
            let(:expected_response_body) do
              {"message"=>"No interaction found for GET /path", "interaction_diffs"=>[{"body"=>{"ACTUAL"=>"\\xEB", "EXPECTED"=>{"a"=>"body"}}, "description"=>"a request"}]}
            end
            
            it "returns the specified response status" do
              expect(response_status).to eq 500
            end
          end
        end

        context "when no request is found with a matching method and path" do
          let(:env) do
            {
              'REQUEST_METHOD' => 'GET',
              'PATH_INFO' => '/another/path',
              'QUERY_STRING' => '',
              'rack.input' => double(read: actual_body)
            }
          end
          let(:expected_response_body) do
            {"message"=>"No interaction found for GET /another/path", "interaction_diffs"=>[]}
          end

          it "returns an 500 error status" do
            expect(response_status).to eq 500
          end

          it "returns a json body" do
            expect(response_headers).to eq "Content-Type"=>"application/json"
          end

          it "returns a list of diffs" do
            expect(response_body).to eq(expected_response_body)
          end

          it "does not add the interaction to the verified interactions list" do
            response
            expect(verified_interactions.size).to eq 0
          end
        end
      end
    end
  end
end

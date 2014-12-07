require 'spec_helper'
require 'pact/consumer/mock_service/interaction_replay'
require 'pact/consumer/mock_service/interaction_list'

module Pact
  module Consumer

    describe InteractionReplay do

      let(:expected_interaction) do
        Interaction.from_hash(
          'description' => 'a request',
          'request' => { 'method' => 'get', 'path' => '/path', 'body' => {'a' => 'body'} },
          'response' => { 'status' => 200, 'headers' => {'some' => 'headers'}, 'body' => {'response' => 'body'} }
        )
      end
      let(:logger) { Logger.new(StringIO.new) }
      let(:interaction_list) { InteractionList.new }
      let(:interactions) { [] }
      let(:actual_body) { {'a' => 'body' } }

      before do
        interaction_list.add expected_interaction
      end

      subject { InteractionReplay.new('provider', logger, interaction_list, interactions) }
      let(:response) { subject.respond env }
      let(:response_body) { JSON.parse(response[2][0]) }
      let(:response_status) { response[0] }
      let(:response_headers) { response[1] }

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
        end

        context "when more than one matching request is found" do
          before do
            interaction_list.add expected_interaction
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
      end
    end
  end
end

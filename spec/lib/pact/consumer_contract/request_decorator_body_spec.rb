require 'spec_helper'
require 'pact/consumer_contract/request_decorator'
require 'pact/consumer/request'
require 'pact/reification'
require 'pact/helpers'

module Pact
  describe RequestDecorator do

    include Pact::Helpers

    let(:body) { {some: Pact::Term.new(generate: 'bod', matcher: /bod/ )} }
    let(:headers) { {some: "header"} }
    let(:request_params) do
      {
        method: :get,
        headers: headers,
        path: "/",
        body: body
      }
    end
    let(:request) { Pact::Request::Expected.from_hash(request_params) }
    let(:parsed_json) { JSON.parse subject.to_json, symbolize_names: true }

    describe "#to_json pact spec v1" do
      subject { RequestDecorator.new(request) }


      context "body" do

        context "with a Content-Type of form and body specified as a hash with a Pact::Term" do
          let(:headers) { { 'Content-Type' => 'application/x-www-form-urlencoded' } }
          let(:body) { {"param" => Pact::Term.new(generate: 'apple', matcher: /a/ )} }

          it "reifies the body for compatibility with pact-specification 1.0.0" do
            expect(parsed_json[:body]).to eq "param=apple"
          end
        end

        context "with a Content-Type of form and body specified as a hash with an array value" do
          let(:headers) { { 'Content-Type' => 'application/x-www-form-urlencoded' } }
          let(:body) { {"param" => ['pear', Pact::Term.new(generate: 'apple', matcher: /a/ )] } }

          it "reifies the body for compatibility with pact-specification 1.0.0" do
            expect(parsed_json[:body]).to eq "param=pear&param=apple"
          end
        end

        context "with no Content-Type and a body specified as a Hash" do
          it "renders the body as JSON" do
            expect(parsed_json[:body]).to eq Pact::Reification.from_term(body)
          end
        end

        context "with a Pact::Term in the JSON body" do
          let(:body) { {"param" => Pact::Term.new(generate: 'apple', matcher: /a/ )} }
          it "reifes the body for compatibility with pact-specification 1.0.0" do
            expect(parsed_json[:body]).to eq param: 'apple'
          end
        end

        context "with a Pact::Term as the body" do
          let(:body) { Pact::Term.new(generate: 'apple', matcher: /a/ ) }
          it "reifes the body for compatibility with pact-specification 1.0.0" do
            expect(parsed_json[:body]).to eq 'apple'
          end
        end

        context "with a String body" do
          let(:body) { "a body" }
          it "renders the String body" do
            expect(parsed_json[:body]).to eq body
          end
        end

      end
    end

    describe '#to_json pact spec v2' do
      subject { RequestDecorator.new(request, { pact_specification_version: '2.0.0' }) }

      context 'body' do

        context 'as a Hash containing param Term' do
          let(:body) { {some: each_like({tester: like('testvalue')})} }

          it 'returns a Hash and generated matchingRules' do
            expect(parsed_json[:body][:some].length).to eq 1
            expect(parsed_json[:body][:some][0][:tester]).to eq 'testvalue'
            expect(parsed_json[:matchingRules][:"$.body.some"][:min]).to eq 1
            expect(parsed_json[:matchingRules][:"$.body.some[*].*"][:match]).to eq 'type'
            expect(parsed_json[:matchingRules][:"$.body.some[*].tester"][:match]).to eq 'type'
          end
        end

        context 'as a Hash containing param ArrayLike' do
          it 'returns a Hash and generated matchingRules' do
            expect(parsed_json[:body][:some]).to eq 'bod'
            expect(parsed_json[:matchingRules][:"$.body.some"][:match]).to eq 'regex'
            expect(parsed_json[:matchingRules][:"$.body.some"][:regex]).to eq 'bod'
          end
        end

        context 'as a Hash with no Terms' do
          let(:body) { {some: 'bod'} }

          it 'returns a Hash with no generated matchingRules' do
            expect(parsed_json[:body][:some]).to eq 'bod'
            expect(parsed_json[:matchingRules]).to eq nil
          end
        end

      end

    end
  end
end

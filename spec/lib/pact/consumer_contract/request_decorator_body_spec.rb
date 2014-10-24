require 'spec_helper'
require 'pact/consumer_contract/request_decorator'
require 'pact/consumer/request'

module Pact
  describe RequestDecorator do

    let(:body) { {some: "bod"} }
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

    subject { RequestDecorator.new(request) }

    describe "#to_json" do

      let(:parsed_json) { JSON.parse subject.to_json, symbolize_names: true }

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
            expect(parsed_json[:body]).to eq body
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
  end
end

require 'spec_helper'
require 'pact/consumer_contract/request_decorator'
require 'pact/consumer/request'

module Pact
  describe RequestDecorator do

    let(:options) { { some: 'opts' } }
    let(:body) { { some: "bod" } }
    let(:headers) { { some: "header" } }
    let(:query) { "param=foo" }
    let(:path) { "/" }
    let(:request_params) do
      {
        method: :get,
        query: query,
        headers: headers,
        path: path,
        body: body,
        options: options
      }
    end
    let(:pact_specification_version) { "1.0" }

    let(:request) { Pact::Request::Expected.from_hash(request_params) }
    subject { RequestDecorator.new(request, pact_specification_version: pact_specification_version) }

    describe "#to_json" do

      let(:parsed_json) { JSON.parse subject.to_json, symbolize_names: true }

      it "renders the keys in a meaningful order" do
        expect(subject.to_json).to match(/method.*path.*query.*headers.*body/)
      end

      it "does not render the options" do
        expect(subject.to_json).to_not include('options')
      end

      describe "path" do

        context "as a Term" do
          let(:path) { Pact::Term.new(generate: "testpath", matcher: /testpath/ ) }

          it "returns a String" do
            expect(parsed_json[:path]).to eq "testpath"
          end
        end

        context "as a String" do
          let(:path) { "testpath" }

          it "returns a String" do
            expect(parsed_json[:path]).to eq "testpath"
          end
        end

      end

      describe "body" do

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

      context "with pact specification version 1.0" do
        let(:pact_specification_version) { "1.0" }

        context "when there are Pact::Terms in the request" do
          let(:query) { Pact::Term.new(matcher: /foo/, generate: "foo") }

          it "does not include matchingRules in the request" do
            expect(parsed_json).to_not have_key :matchingRules
          end
        end
      end

      context "with pact specification version 2.0" do
        let(:pact_specification_version) { "2.0" }

        context "when there are Pact::Terms in the request" do
          let(:query) { Pact::Term.new(matcher: /foo/, generate: "foo") }

          it "incudes the matching rules for the terms" do
            expect(parsed_json[:matchingRules]).to_not be_nil
          end
        end
      end


      context "when the path is a Pact::Term" do
        let(:request_params) do
          {
            method: :get, path: Pact::Term.new(matcher: %r{/alligators/.*}, generate: '/alligators/Mary')
          }
        end

        it "reifies the path" do
          expect(parsed_json[:path]).to eq '/alligators/Mary'
        end
      end
    end
  end
end

require 'pact/consumer_contract/response'

shared_examples_for "request decorator to_json" do

  describe "#to_json" do

    let(:response) { Pact::Response.new(status: 200, body: body) }
    let(:body) { { baz: /qux/, wiffle: Pact::Term.new(generate: 'wiffle', matcher: /iff/) } }

    let(:decorator) { described_class.new(response) }

    subject { JSON.load decorator.to_json }

    it "serialises regexes" do
      expect(subject['body']['baz']).to eql /qux/
    end

    it "serialises terms" do
      parsed_term = subject['body']['wiffle']
      expect(parsed_term.matcher).to eql /iff/
      expect(parsed_term.generate).to eql 'wiffle'
    end

  end
end

require 'pact/consumer_contract/consumer_contract_decorator'

module Pact
  describe ConsumerContractDecorator do
    let(:consumer) { ServiceConsumer.new(name: 'Consumer') }
    let(:provider) { ServiceProvider.new(name: 'Provider') }
    let(:consumer_contract) { Pact::ConsumerContract.new(consumer: consumer, provider: provider, interactions: interactions) }
    let(:pact_specification_version) { '1' }
    subject { ConsumerContractDecorator.new(consumer_contract, pact_specification_version: pact_specification_version) }

    describe "to_json" do
      let(:interactions) { [] }
      let(:parsed_json) { JSON.parse(subject.to_json, symbolize_names: true) }

      context "when pact_specification_version is 1" do
        let(:pact_specification_version) { '1' }
        it "sets the pactSpecificationVersion to 1.0.0" do
          expect(parsed_json[:metadata][:pactSpecificationVersion]).to eq '1.0.0'
        end
      end

      context "when pact_specification_version is 2" do
        let(:pact_specification_version) { '2' }
        it "sets the pactSpecificationVersion to 2.0.0" do
          expect(parsed_json[:metadata][:pactSpecificationVersion]).to eq '2.0.0'
        end
      end

      context "when pact_specification_version is 2.1 because there is no 2.1 yet." do
        let(:pact_specification_version) { '2.1' }
        it "sets the pactSpecificationVersion to 2.0.0" do
          expect(parsed_json[:metadata][:pactSpecificationVersion]).to eq '2.0.0'
        end
      end

    end
    describe "as_json" do
      context "with multiple interactions" do
        let(:interaction_1) { InteractionFactory.create(provider_state: 'BBB')  }
        let(:interaction_2) { InteractionFactory.create(provider_state: 'AAA')}
        let(:interactions) { [interaction_1, interaction_2] }


        it "sorts interactions by provider_state" do
          expect(subject.as_json[:interactions]).to eq([
            InteractionDecorator.new(interaction_2, pact_specification_version: pact_specification_version).as_json, 
            InteractionDecorator.new(interaction_1, pact_specification_version: pact_specification_version).as_json
            ])
        end
      end
    end
    
  end
end

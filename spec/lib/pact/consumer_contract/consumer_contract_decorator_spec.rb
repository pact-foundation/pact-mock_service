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
        it "sets the pactSpecification.version to 1.0.0" do
          expect(parsed_json[:metadata][:pactSpecification][:version]).to eq '1.0.0'
        end
      end

      context "when pact_specification_version is 2" do
        let(:pact_specification_version) { '2' }
        it "sets the pactSpecification.version to 2.0.0" do
          expect(parsed_json[:metadata][:pactSpecification][:version]).to eq '2.0.0'
        end
      end

      context "when pact_specification_version is 2.1 because there is no 2.1 yet." do
        let(:pact_specification_version) { '2.1' }
        it "sets the pactSpecification.version to 2.0.0" do
          expect(parsed_json[:metadata][:pactSpecification][:version]).to eq '2.0.0'
        end
      end

    end
    
    describe "as_json" do
      context "with multiple interactions" do
        let(:desc_2) { 'Desc 1' }
        let(:status_2) { 200 }
        let(:provider_state_2) { 'State 1' }
        let(:interaction_1) do
          InteractionFactory.create(
            provider_state: 'State 2',
            description: 'Desc 2',
            response: {
              status: 201
            })
        end
        let(:interaction_2) do
          InteractionFactory.create(
            provider_state: provider_state_2,
            description: desc_2,
            response: {
              status: status_2
            })
        end
        let(:interactions) { [interaction_1, interaction_2] }

        it "sorts interactions in recorded order by default" do
          expect(subject.as_json[:interactions]).to eq([
            InteractionDecorator.new(interaction_1, pact_specification_version: pact_specification_version).as_json,
            InteractionDecorator.new(interaction_2, pact_specification_version: pact_specification_version).as_json,
          ])
        end

        context "when pactfile_write_order is set to :chronological" do
          before do
            Pact.configuration.pactfile_write_order = :chronological
          end

          it "sorts interactions in recorded order" do
            expect(subject.as_json[:interactions]).to eq([
              InteractionDecorator.new(interaction_1, pact_specification_version: pact_specification_version).as_json,
              InteractionDecorator.new(interaction_2, pact_specification_version: pact_specification_version).as_json,
            ])
          end
        end

        context "when pactfile_write_order is set to :alphabetical" do
          before do
            Pact.configuration.pactfile_write_order = :alphabetical
          end

          context "and interactions have different provider state" do
            let(:desc_2) { 'Desc 2' }
            let(:status_2) { 201 }
            it "sorts interactions in alphabetical order by provider state" do
              expect(subject.as_json[:interactions]).to eq([
                InteractionDecorator.new(interaction_2, pact_specification_version: pact_specification_version).as_json,
                InteractionDecorator.new(interaction_1, pact_specification_version: pact_specification_version).as_json,
              ])
            end
          end

          context "and interactions have different description" do
            let(:status_2) { 201 }
            let(:provider_state_2) { 'State 2' }

            it "sorts interactions in alphabetical order by description" do
              expect(subject.as_json[:interactions]).to eq([
                InteractionDecorator.new(interaction_2, pact_specification_version: pact_specification_version).as_json,
                InteractionDecorator.new(interaction_1, pact_specification_version: pact_specification_version).as_json,
              ])
            end
          end
          context "and interactions have different provider state" do
            let(:status_2) { 201 }
            let(:desc_2) { 'Desc 2' }

            it "sorts interactions in alphabetical order by description" do
              expect(subject.as_json[:interactions]).to eq([
                InteractionDecorator.new(interaction_2, pact_specification_version: pact_specification_version).as_json,
                InteractionDecorator.new(interaction_1, pact_specification_version: pact_specification_version).as_json,
              ])
            end
          end
        end

        context "when pactfile_write_order does not have a correct value" do
          before do
            Pact.configuration.pactfile_write_order = :not_implemented
          end

          it "fails" do
            expect{ subject.as_json[:interactions] }.to raise_error NotImplementedError
          end
        end
      end

      context "when an interaction is marked to not be written" do
        before do
          Pact.configuration.pactfile_write_order = :chronological
        end

        let(:interaction_1) do
          InteractionFactory.create(
            provider_state: 'State 1',
            description: 'Desc 1',
            response: {
              status: 201
            })
        end
        let(:interaction_2) do
          InteractionFactory.create(
            provider_state: 'State 2',
            description: 'Desc 2',
            response: {
              status: 201
            },
            metadata: {
              write_to_pact: true
            })
        end
        let(:interaction_3) do
          InteractionFactory.create(
            provider_state: 'State 3',
            description: 'Desc 3',
            response: {
              status: 201
            },
            metadata: {
              write_to_pact: false
            })
        end
        let(:interactions) { [interaction_1, interaction_2, interaction_3] }

        it "only renders writable interactions" do
          expect(subject.as_json[:interactions]).to eq([
            InteractionDecorator.new(interaction_1, pact_specification_version: pact_specification_version).as_json,
            InteractionDecorator.new(interaction_2, pact_specification_version: pact_specification_version).as_json
          ])
        end
      end
    end
  end
end

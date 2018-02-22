require 'spec_helper'
require 'pact/consumer_contract/consumer_contract_writer'

module Pact

  describe ConsumerContractWriter do

    let(:support_pact_file) { './spec/support/a_consumer-a_provider.json' }
    let(:consumer_name) { 'a consumer' }
    let(:provider_name) { 'a provider' }
    let(:target_pact_file_location) { "#{tmp_pact_dir}/a_consumer-a_provider.json" }

    before do
      Pact.clear_configuration
      FileUtils.rm_rf tmp_pact_dir
      FileUtils.mkdir_p tmp_pact_dir
      FileUtils.cp support_pact_file, target_pact_file_location
    end

    let(:existing_interactions) { ConsumerContract.from_json(File.read(support_pact_file)).interactions }
    let(:new_interactions) { [InteractionFactory.create] }
    let(:tmp_pact_dir) { "./tmp/pacts" }
    let(:logger) { double("logger").as_null_object }
    let(:pactfile_write_mode) { :overwrite }
    let(:pact_specification_version) { nil }
    let(:consumer_contract_details) {
      {
          consumer: { name: consumer_name },
          provider: { name: provider_name },
          pactfile_write_mode: pactfile_write_mode,
          interactions: new_interactions,
          pact_dir: tmp_pact_dir,
          pact_specification_version: pact_specification_version
      }
    }

    let(:consumer_contract_writer) { ConsumerContractWriter.new(consumer_contract_details, logger) }

    describe "#write" do
      it "writes the pact file to the pact_dir" do
        FileUtils.rm_rf target_pact_file_location
        consumer_contract_writer.write
        expect(File.exist?(target_pact_file_location)).to be true
      end

      context "when overwriting pact" do

        it "it uses only the interactions from the current test run" do
          consumer_contract_writer.write
          expect(Pact::ConsumerContract.from_json(File.read(target_pact_file_location)).interactions.collect(&:to_hash)).to eq new_interactions.collect(&:to_hash)
        end

      end

      context "when updating pact" do

        let(:pactfile_write_mode) { :update }

        it "merges the interactions from the current test run with the interactions from the existing file" do
          allow_any_instance_of(ConsumerContractWriter).to receive(:info_and_puts)
          consumer_contract_writer.write
          expect(Pact::ConsumerContract.from_uri(target_pact_file_location).interactions.size).to eq 3
        end

        let(:line0) { "*" * 77 }
        let(:line1) { %r{Updating existing file} }
        let(:line2) { %r{Only interactions defined in this test run will be updated} }
        let(:line3) { %r{As interactions are identified by description and provider state} }

        it "logs a description message" do
          expect($stdout).to receive(:puts).with(line0).twice
          expect($stdout).to receive(:puts).with(line1)
          expect($stdout).to receive(:puts).with(line2)
          expect($stdout).to receive(:puts).with(line3)
          expect(logger).to receive(:info).with(line0).twice
          expect(logger).to receive(:info).with(line1)
          expect(logger).to receive(:info).with(line2)
          expect(logger).to receive(:info).with(line3)
          consumer_contract_writer.write
        end
      end

      context "when an error occurs deserializing the existing pactfile" do

        let(:pactfile_write_mode) { :update }
        let(:error) { RuntimeError.new('some error')}
        let(:line1) { %r{Could not load existing consumer contract from .* due to} }

        before do
          File.open(target_pact_file_location, "w") { |file| file << "wiffle"  }

          allow($stderr).to receive(:puts)
          allow(logger).to receive(:puts)
        end

        after do
          FileUtils.rm(target_pact_file_location)
        end

        it "logs the error" do
          expect($stderr).to receive(:puts).with(line1)
          expect(logger).to receive(:warn).with(line1)
          consumer_contract_writer.write
        end

        it "uses the new interactions" do
          expect(consumer_contract_writer.consumer_contract.interactions).to eq new_interactions
        end
      end

      context "when pactfile_write_mode is update" do
        let(:pactfile_write_mode) { :update }
        let(:new_interactions) { [InteractionFactory.create] }

        before do
          allow($stdout).to receive(:puts)
        end

        it "merges in the existing interactions" do
          consumer_contract_writer.write
          pact_hash =JSON.parse(File.read(target_pact_file_location))
          expect(pact_hash['interactions'].size).to eq 3
        end
      end

      context "when pactfile_write_mode is none" do
        let(:pactfile_write_mode) { :none }
        before { FileUtils.rm_rf target_pact_file_location }

        it "does not write the pact file" do
          consumer_contract_writer.write
          expect(File.exist?(target_pact_file_location)).to be false
        end
      end

      context "when the pact_dir is not specified" do
        let(:consumer_contract_details) {
          {
              consumer: { name: consumer_name },
              provider: { name: provider_name },
              pactfile_write_mode: pactfile_write_mode,
              interactions: new_interactions
          }
        }

        it "raises an error" do
          expect{ consumer_contract_writer.write }.to raise_error ConsumerContractWriterError, /Please indicate the directory/
        end
      end

      context "when no pact_specification_version is specified" do
        let(:pact_specification_version) { nil }
        it "defaults to 2" do
          expect(Pact::ConsumerContractDecorator).to receive(:new).with(anything, hash_including(pact_specification_version: '2.0.0')).and_call_original
          consumer_contract_writer.write
        end
      end

      context "when a pact_specification_version is specified" do
        let(:pact_specification_version) { '1.0' }
        it "uses the specified version" do
          expect(Pact::ConsumerContractDecorator).to receive(:new).with(anything, hash_including(pact_specification_version: '1.0')).and_call_original
          consumer_contract_writer.write
        end
      end

      context "when a numeric pact_specification_version is specified" do
        let(:pact_specification_version) { 1 }
        it "converts it to a String" do
          expect(Pact::ConsumerContractDecorator).to receive(:new).with(anything, hash_including(pact_specification_version: '1')).and_call_original
          consumer_contract_writer.write
        end
      end
    end
  end
end

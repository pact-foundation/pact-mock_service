require 'pact/consumer_contract'
require 'pact/mock_service/interactions/interactions_filter'
require 'pact/consumer_contract/file_name'
require 'pact/consumer_contract/pact_file'
require 'pact/consumer_contract/consumer_contract_decorator'
require 'pact/shared/active_support_support'
require 'fileutils'

module Pact

  class ConsumerContractWriterError < StandardError; end

  class ConsumerContractWriter

    DEFAULT_PACT_SPECIFICATION_VERSION = '1.0.0'

    include Pact::FileName
    include Pact::PactFile
    include ActiveSupportSupport

    def initialize consumer_contract_details, logger
      @logger = logger
      @consumer_contract_details = consumer_contract_details
      @pactfile_write_mode = consumer_contract_details.fetch(:pactfile_write_mode, :overwrite).to_sym
      @interactions = consumer_contract_details.fetch(:interactions)
      @pact_specification_version = (consumer_contract_details[:pact_specification_version] || DEFAULT_PACT_SPECIFICATION_VERSION).to_s
    end

    def consumer_contract
      @consumer_contract ||= Pact::ConsumerContract.new(
        consumer: ServiceConsumer.new(name: consumer_contract_details[:consumer][:name]),
        provider: ServiceProvider.new(name: consumer_contract_details[:provider][:name]),
        interactions: interactions_for_new_consumer_contract)
    end

    def write
      update_pactfile
      pact_json
    end

    def can_write?
      consumer_name && provider_name && consumer_contract_details[:pact_dir]
    end

    private

    attr_reader :consumer_contract_details, :pactfile_write_mode, :interactions, :logger, :pact_specification_version

    def update_pactfile
      logger.info log_message

      FileUtils.mkdir_p File.dirname(pactfile_path)
      new_pact_json = pact_json
      File.open(pactfile_path, 'w') do |f|
        f.write new_pact_json
      end
    end

    def pact_json
      @pact_json ||= fix_json_formatting(JSON.pretty_generate(decorated_pact))
    end

    def decorated_pact
      @decorated_pact ||= Pact::ConsumerContractDecorator.new(consumer_contract, pact_specification_version: pact_specification_version)
    end

    def interactions_for_new_consumer_contract
      if updating?
        merged_interactions = existing_interactions.dup
        filter = Pact::MockService::Interactions::UpdatableInteractionsFilter.new(merged_interactions)
        interactions.each {|i| filter << i }
        merged_interactions
      else
        interactions
      end
    end

    def existing_interactions
      interactions = []
      if pactfile_exists?
        begin
          interactions = existing_consumer_contract.interactions
          info_and_puts "*****************************************************************************"
          info_and_puts "Updating existing file .#{pactfile_path.gsub(Dir.pwd, '')} as config.pactfile_write_mode is :update"
          info_and_puts "Only interactions defined in this test run will be updated."
          info_and_puts "As interactions are identified by description and provider state, pleased note that if either of these have changed, the old interactions won't be removed from the pact file until the specs are next run with :pactfile_write_mode => :overwrite."
          info_and_puts "*****************************************************************************"
        rescue StandardError => e
          warn_and_stderr "Could not load existing consumer contract from #{pactfile_path} due to #{e}"
          logger.error e
          logger.error e.backtrace
          warn_and_stderr "Creating a new file."
        end
      end
      interactions
    end

    def pactfile_exists?
      File.exist?(pactfile_path)
    end

    def existing_consumer_contract
      Pact::ConsumerContract.from_uri(pactfile_path)
    end

    def warn_and_stderr msg
      Pact.configuration.error_stream.puts msg
      logger.warn msg
    end

    def info_and_puts msg
      $stdout.puts msg
      logger.info msg
    end

    def consumer_name
      consumer_contract_details[:consumer][:name]
    end

    def provider_name
      consumer_contract_details[:provider][:name]
    end

    def pactfile_path
      raise 'You must specify a consumer and provider name' unless (consumer_name && provider_name)
      file_path consumer_name, provider_name, pact_dir
    end

    def pact_dir
      unless consumer_contract_details[:pact_dir]
        raise ConsumerContractWriterError.new("Please indicate the directory to write the pact to by specifying the pact_dir field")
      end
      consumer_contract_details[:pact_dir]
    end

    def updating?
      pactfile_write_mode == :update
    end

    def log_message
      if updating?
        "Updating pact for #{provider_name} at #{pactfile_path}"
      else
        "Writing pact for #{provider_name} to #{pactfile_path}"
      end
    end
  end
end

require 'pact/mock_service/cli/custom_thor'

class Pact::MockService::CLI

  class Delegate
    def self.call options; end
  end

  class TestThor < CustomThor
    desc 'ARGUMENT', 'This is the description'
    def test_default(argument)
      Delegate.call(argument: argument)
    end

    desc '', ''
    method_option :multi, type: :array
    def test_multiple_options
      Delegate.call(options)
    end

    default_command :test_default
  end

  describe CustomThor do
    subject { TestThor.new }

    it "invokes the default task when aguments are given without specifying a task" do
      expect(Delegate).to receive(:call).with(argument: 'foo')
      TestThor.start(%w{foo})
    end

    it "converts options that are specified multiple times into a single array" do
      expect(Delegate).to receive(:call).with({'multi' => ['one', 'two']})
      TestThor.start(%w{test_multiple_options --multi one --multi two})
    end

    describe ".prepend_default_task_name" do
      let(:argv_with) { [TestThor.default_command, 'foo'] }

      context "when the default task name is given" do
        it "does not prepend the default task name" do
          expect(TestThor.prepend_default_task_name(argv_with)).to eq(argv_with)
        end
      end

      context "when the first argument is --help" do
        let(:argv) { ['--help', 'foo'] }

        it "does not prepend the default task name" do
          expect(TestThor.prepend_default_task_name(argv)).to eq(argv)
        end
      end

      context "when the default task name is not given" do
        let(:argv) { ['foo'] }

        it "prepends the default task name" do
          expect(TestThor.prepend_default_task_name(argv)).to eq(argv_with)
        end
      end
    end

    describe ".turn_muliple_tag_options_into_array" do
      it "turns '--tag foo --tag bar' into '--tag foo bar'" do
        input = %w{--ignore this --tag foo --tag bar --wiffle --that}
        output = %w{--ignore this --tag foo bar --wiffle --that }
        expect(TestThor.turn_muliple_tag_options_into_array(input)).to eq output
      end

      it "turns '--tag foo bar --tag meep' into '--tag foo meep bar'" do
        input = %w{--ignore this --tag foo bar --tag meep --wiffle --that}
        output = %w{--ignore this --tag foo meep bar --wiffle --that}
        expect(TestThor.turn_muliple_tag_options_into_array(input)).to eq output
      end

      it "turns '--tag foo --tag bar wiffle' into '--tag foo bar wiffle' which is silly" do
        input = %w{--ignore this --tag foo --tag bar wiffle}
        output = %w{--ignore this --tag foo bar wiffle}
        expect(TestThor.turn_muliple_tag_options_into_array(input)).to eq output
      end

      it "maintains '--tag foo bar wiffle'" do
        input = %w{--ignore this --tag foo bar wiffle --meep}
        output = %w{--ignore this --tag foo bar wiffle --meep}
        expect(TestThor.turn_muliple_tag_options_into_array(input)).to eq output
      end

      it "turns '-t foo -t bar' into '-t foo bar'" do
        input = %w{--ignore this -t foo -t bar --meep --that 1 2 3}
        output = %w{--ignore this -t foo bar --meep --that 1 2 3}
        expect(TestThor.turn_muliple_tag_options_into_array(input)).to eq output
      end

      it "doesn't change anything when there are no duplicate options" do
        input = %w{--ignore this --taggy foo --blah bar --wiffle --that}
        expect(TestThor.turn_muliple_tag_options_into_array(input)).to eq input
      end

      it "return an empty array when given an empty array" do
        input = []
        expect(TestThor.turn_muliple_tag_options_into_array(input)).to eq input
      end
    end
  end
end

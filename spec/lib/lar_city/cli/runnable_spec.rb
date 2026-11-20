# frozen_string_literal: true

require 'rails_helper'
require 'thor'

RSpec.describe LarCity::CLI::Runnable do
  let(:runner_class) do
    Class.new(Thor) do
      include LarCity::CLI::Runnable

      # Expose the protected #run for the examples below, without Thor
      # registering it as a command
      no_commands { public :run }
    end
  end

  let(:runner) { runner_class.new([], {}) }
  let(:cmd) { "printf 'first\\nsecond\\n'" }

  describe '#run with a block' do
    context 'when the IO mode is eval' do
      it 'yields each line and returns the collected output' do
        lines = []
        result = runner.run(cmd, io_mode: 'eval_with_result') { |line| lines << line }

        expect(lines).to eq(%W[first\n second\n])
        expect(result).to eq("first\nsecond\n")
      end

      it 'keeps collecting output when the block itself calls #run' do
        # A nested #run resets the runner's IO mode, so the outer call must not
        # re-read the mode after it has started streaming.
        result = runner.run(cmd, io_mode: 'eval_with_result') { |_line| runner.run('true') }

        expect(result).to eq("first\nsecond\n")
      end
    end

    context 'when the IO mode is not eval' do
      it 'still yields every line and returns the process status instead of the output' do
        lines = []
        result = runner.run(cmd, io_mode: 'inline_with_result') { |line| lines << line }

        expect(lines).to eq(%W[first\n second\n])
        expect(result).to be_a(Process::Status)
        expect(result).to be_success
      end
    end
  end
end

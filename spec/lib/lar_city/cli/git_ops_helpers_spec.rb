# frozen_string_literal: true

require 'rails_helper'
require 'lar_city/cli/git_ops_helpers'
require 'thor'

RSpec.describe LarCity::CLI::GitOpsHelpers do
  describe '.included' do
    let(:base_class) { Class.new(Thor) }

    before do
      allow(LarCity::CLI::GitOpsHelpers).to receive(:require_thor_options_support!)
    end

    it 'calls require_thor_options_support! and includes necessary modules' do
      base_class.include(LarCity::CLI::GitOpsHelpers)

      expect(LarCity::CLI::GitOpsHelpers).to have_received(:require_thor_options_support!).with(base_class)
      expect(base_class.ancestors).to include(LarCity::CLI::OutputHelpers)
      expect(base_class.ancestors).to include(LarCity::CLI::Runnable)
      expect(base_class.ancestors).to include(LarCity::CLI::GitOpsHelpers::InstanceMethods)
    end

    context 'when included in a non-Thor class' do
      let(:non_thor_class) { Class.new }

      it 'raises an error' do
        # We need to un-mock it for this test
        allow(LarCity::CLI::GitOpsHelpers).to receive(:require_thor_options_support!).and_call_original
        expect do
          non_thor_class.include(LarCity::CLI::GitOpsHelpers)
        end.to raise_error(RuntimeError, /is not a descendant of Thor/)
      end
    end
  end

  describe 'InstanceMethods' do
    let(:dummy_class) do
      Class.new(Thor) do
        include LarCity::CLI::GitOpsHelpers

        # We need to expose the protected methods for testing
        no_commands do
          public :require_gh_cli!, :current_branch, :branches
        end
      end
    end

    let(:dummy_instance) { dummy_class.new }

    describe '#require_gh_cli!' do
      context 'when gh is installed' do
        before do
          allow(dummy_instance).to receive(:run)
                                     .with('which gh > /dev/null 2>&1', mock_return: true, eval: false, inline: true)
                                     .and_return(true)
        end

        it 'returns nil and does not raise an error' do
          expect(dummy_instance.require_gh_cli!).to be_nil
        end
      end

      context 'when gh is not installed' do
        before do
          allow(dummy_instance).to receive(:run)
                                     .with('which gh > /dev/null 2>&1', mock_return: true, eval: false, inline: true)
                                     .and_return(false)
          allow(dummy_instance).to receive(:say_warning)
        end

        it 'warns the user and raises Thor::Error' do
          expect do
            dummy_instance.require_gh_cli!
          end.to raise_error(Thor::Error, 'GitHub CLI (gh) is required but not found in PATH.')
          expect(dummy_instance).to have_received(:say_warning).with(%r{The 'gh' CLI tool is not installed})
        end
      end
    end

    describe '#current_branch' do
      it 'returns the current git branch' do
        allow(dummy_instance).to receive(:`).with('git rev-parse --abbrev-ref HEAD').and_return("main\n")
        expect(dummy_instance.current_branch).to eq('main')
      end

      it 'caches the result' do
        expect(dummy_instance).to receive(:`).with('git rev-parse --abbrev-ref HEAD').once.and_return("main\n")
        dummy_instance.current_branch
        dummy_instance.current_branch
      end
    end

    describe '#branches' do
      it 'returns an array of indexed branches' do
        git_output = "  branch-1\n* main\n  feature/xyz"
        allow(dummy_instance).to receive(:`).with('git branch --list').and_return(git_output)
        expect(dummy_instance.branches).to eq([
                                                [0, 'branch-1'],
                                                [1, 'main'],
                                                [2, 'feature/xyz'],
                                              ])
      end

      it 'handles empty branch list' do
        allow(dummy_instance).to receive(:`).with('git branch --list').and_return('')
        expect(dummy_instance.branches).to eq([])
      end

      it 'handles a single branch' do
        allow(dummy_instance).to receive(:`).with('git branch --list').and_return('* main')
        expect(dummy_instance.branches).to eq([[0, 'main']])
      end

      it 'caches the result' do
        git_output = "  branch-1\n* main\n  feature/xyz"
        expect(dummy_instance).to receive(:`).with('git branch --list').once.and_return(git_output)
        dummy_instance.branches
        dummy_instance.branches
      end
    end
  end
end

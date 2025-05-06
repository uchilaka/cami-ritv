# frozen_string_literal: true

require 'rails_helper'

load_lib_script 'commands', 'hello_cmd', ext: 'thor'

RSpec.describe HelloCmd, type: :thor, devtool: true, skip_in_ci: true do
  let(:command) { described_class.new }

  describe 'hello' do
    context 'when no name is provided' do
      it 'says hello to the world' do
        expect { command.invoke(:hello) }.to output(/👋🏽 Hello, world!/).to_stdout
      end
    end

    context 'when a name is provided' do
      it 'says hello to the provided name' do
        expect { command.invoke(:hello, [], name: 'Alice') }.to output(/👋🏽 Hello, Alice!/).to_stdout
      end
    end

    context 'when the operating system is detected' do
      before do
        # TODO: This doesn't _really_ work the way it should.
        #   The `friendly_os_name` method is not being stubbed correctly.
        #   Review the `OperatingSystemDetectable` module to dig into the
        #   details, but the TL;DR is that module is doing some metaprogramming
        #   that is not being accounted for in this test. It can probably be
        #   much simpler with the goal of declaring the methods defined as both
        #   class and instance methods when the module is included.
        allow(command).to receive(:friendly_os_name).and_return(:linux)
      end

      it 'includes the operating system in the output' do
        expect { command.invoke(:hello) }.to output(/You're running on/).to_stdout
      end
    end

    context 'when the operating system is unsupported' do
      before do
        allow(command).to receive(:friendly_os_name).and_return(:unsupported)
      end

      it 'does not include the operating system in the output' do
        expect { command.invoke(:hello) }.to output(/👋🏽 Hello, world!/).to_stdout
      end
    end
  end
end

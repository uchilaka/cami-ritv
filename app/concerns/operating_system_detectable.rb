# frozen_string_literal: true

require 'rbconfig'
require 'ostruct'

module OperatingSystemDetectable
  def self.included(base)
    # Define the class methods on the base class.
    base.extend(ClassMethods)
    library_methods =
      ClassMethods
        .instance_methods(false)
        .reject { |method_name| method_name == :included }
    library_methods.each do |method_name|
      # Define the instance method on the base class.
      base.define_method(method_name) do |*args, &block|
        # Call the original class method on the module.
        self.class.send(method_name, *args, &block)
      end
    end
  end

  module ClassMethods
    # Check OS with Ruby: https://gist.github.com/havenwood/4161944
    def mac?
      friendly_os_name == :macos
    end

    def linux?
      friendly_os_name == :linux
    end

    def windows?
      friendly_os_name == :windows
    end

    def human_friendly_os_name
      human_friendly_os_names_map[friendly_os_name]
    end

    def friendly_os_name
      case RbConfig::CONFIG['host_os']
      when /linux/
        :linux
      when /darwin/
        :macos
      when /mswin|mingw32|windows/
        :windows
      when /solaris/
        :solaris
      when /bsd/
        :bsd
      else
        :unsupported
      end
    end

    def human_friendly_os_names_map
      {
        linux: 'Linux',
        macos: 'macOS',
        windows: 'Windows',
        solaris: 'Solaris',
        bsd: 'BSD',
        unsupported: 'Unsupported'
      }
    end
  end
end

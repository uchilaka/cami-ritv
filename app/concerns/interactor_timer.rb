# frozen_string_literal: true

module InteractorTimer
  extend ActiveSupport::Concern

  included do
    raise LarCity::MissingRequiredModule, "#{name} requires Interactor" \
      unless include?(Interactor)

    around do |interactor|
      context.start_time = Time.zone.now
      interactor.call
      context.finish_time = Time.zone.now
      context.execution_time = context.finish_time - context.start_time
    end
  end
end

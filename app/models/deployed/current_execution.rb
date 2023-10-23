# frozen_string_literal: true

module Deployed
  # Provides a way to track the current child_pid
  class CurrentExecution < ActiveSupport::CurrentAttributes
    attribute :child_pid
  end
end

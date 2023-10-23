# frozen_string_literal: true

module Deployed
  class ApplicationController < ActionController::Base
    layout 'deployed/application'

    helper Deployed::Engine.helpers

    before_action :initialize_deployed

    private

    # A bunch of housekeeping stuff to make things run
    def initialize_deployed
      Deployed.setup!
    end
  end
end

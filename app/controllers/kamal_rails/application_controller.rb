# frozen_string_literal: true

module KamalRails
  class ApplicationController < ActionController::Base
    layout 'kamal_rails/application'

    helper KamalRails::Engine.helpers

    before_action :initialize_kamal_rails

    private

    # A bunch of housekeeping stuff to make things run
    def initialize_kamal_rails
      KamalRails.setup!
    end
  end
end

# frozen_string_literal: true

module Deployed
  # Provides the main entry point for the app
  class WelcomeController < ApplicationController
    def index
      respond_to(&:html)
    end
  end
end

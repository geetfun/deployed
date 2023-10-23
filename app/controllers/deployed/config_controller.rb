# frozen_string_literal: true

module Deployed
  # Provides information on the current ./config/deploy.yml
  class ConfigController < ApplicationController
    def show
      respond_to(&:html)
    end
  end
end

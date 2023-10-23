# frozen_string_literal: true

module KamalRails
  # Provides information on the current ./config/deploy.yml
  class ConfigController < ApplicationController
    def show
      respond_to(&:html)
    end
  end
end

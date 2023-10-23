# frozen_string_literal: true

module Deployed
  # Provides a way to setup ./config/deploy.yml
  class SetupController < ApplicationController
    def new
      respond_to do |format|
        format.html
      end
    end

    def create
      `kamal init`

      respond_to do |format|
        format.html { redirect_to root_path }
      end
    end
  end
end

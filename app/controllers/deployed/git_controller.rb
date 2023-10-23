# frozen_string_literal: true

module Deployed
  # Provides a git status check to see if we are deploying uncommitted changes
  class GitController < ApplicationController
    def uncommitted_check
      @git_status = `git status --porcelain`
      respond_to(&:html)
    end
  end
end

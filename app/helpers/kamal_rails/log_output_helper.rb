# frozen_string_literal: true

module KamalRails
  module LogOutputHelper
    def deploy_output_intro
      output = <<~HTML
        <div>Ready... Set... Deploy!</div>
      HTML

      output.html_safe
    end

    def deploy_output_kamal_version
      output = <<~HTML
        <div>
          Using <span class="text-slate-300">kamal #{::Kamal::VERSION}</span>
        </div>
      HTML

      output.html_safe
    end

    def deploy_output_missing_config
      return unless KamalRails::DeployConfig.requires_init

      output = <<~HTML
        <div class="text-red-500">WARNING: ./config/deploy.yml file not detected</div>
      HTML

      output.html_safe
    end

    def deploy_output_spinner
      output = <<~HTML
        <div id="spinner" class="hidden mt-2 pb-4">
          <svg class="animate-spin -ml-1 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
        </div>
      HTML

      output.html_safe
    end

    def deploy_output_resize_handler
      output = <<~ICON
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
          <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 12a.75.75 0 11-1.5 0 .75.75 0 011.5 0zM12.75 12a.75.75 0 11-1.5 0 .75.75 0 011.5 0zM18.75 12a.75.75 0 11-1.5 0 .75.75 0 011.5 0z" />
        </svg>
      ICON

      output.html_safe
    end
  end
end

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

    def lock_file_path
      Rails.root.join(Deployed::DIRECTORY, 'process.lock')
    end

    def lock_process
      File.open(lock_file_path, 'a') do |file|
        file.puts(Deployed::CurrentExecution.child_pid)
      end
    end

    def release_process
      return unless File.exist?(lock_file_path)

      File.delete(lock_file_path)
    end

    def stored_pid
      return false unless File.exist?(lock_file_path)

      value = File.read(lock_file_path).to_i

      if value.is_a?(Integer)
        value
      else
        false
      end
    end

    def process_running?
      return false unless stored_pid

      begin
        # Send signal 0 to the process to check if it exists
        Process.kill(0, stored_pid)
        true
      rescue Errno::ESRCH
        false
      end
    end
    helper_method :process_running?
  end
end

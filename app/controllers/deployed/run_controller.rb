# frozen_string_literal: true

module Deployed
  # Provides a centralized way to run all `kamal [command]` executions and streams to the browser
  class RunController < ApplicationController
    class ConcurrentProcessRunning < StandardError; end
    skip_forgery_protection

    # Endpoint to execute the kamal command
    def execute
      raise(ConcurrentProcessRunning) if process_running?
      release_process if stored_pid
      File.write(current_log_file, '')

      # Fork a child process
      Deployed::CurrentExecution.child_pid = fork do
        exec("bundle exec rake deployed:execute_and_log['#{command}']")
      end

      lock_process
      render json: { message: 'OK' }
    rescue ConcurrentProcessRunning
      render json: { message: 'EXISTING PROCESS' }
    end

    # Endpoint to cancel currently running process
    def cancel
      pid = stored_pid
      if process_running?
        # If a process is running, get the PID and attempt to kill it
        begin
          Process.kill('TERM', stored_pid)
        rescue Errno::ESRCH
        ensure
          release_process
        end
      end
      render json: { message: pid }
    end

    private

    def command
      params[:command]
    end
  end
end

# frozen_string_literal: true

module KamalRails
  # Provides a centralized way to run all `kamal [command]` executions and streams to the browser
  class RunController < ApplicationController
    class ConcurrentProcessRunning < StandardError; end

    include ActionController::Live

    before_action :set_headers

    # Endpoint to execute the kamal command
    def execute
      if process_running?
        raise(ConcurrentProcessRunning)
      elsif stored_pid
        release_process
      end

      sse.write(
        "<div class='text-slate-400'>> <span class='text-slate-300 font-semibold'>kamal #{command}</span></div>",
        event: 'message'
      )

      read_io, write_io = IO.pipe

      # Fork a child process
      KamalRails::CurrentExecution.child_pid = fork do
        # Redirect the standard output to the write end of the pipe
        $stdout.reopen(write_io)

        # Execute the command
        exec("kamal #{command}; echo \"[Kamal Rails] End transmission\"")
      end

      lock_process

      sse.write(
        "<div class='text-slate-400' data-child-pid=\"#{KamalRails::CurrentExecution.child_pid}\"></div>",
        event: 'message'
      )

      write_io.close

      # Use a separate thread to read and stream the output
      output_thread = Thread.new do
        read_io.each_line do |line|
          output = line.strip
          output = output.gsub('49.13.91.176', '[redacted]')
          text_color_class = 'text-green-400'

          # Hackish way of dealing with error messages at the moment
          if output.include?('[31m')
            text_color_class = 'text-red-500'
            output.gsub!('[31m', '')
            output.gsub!('[0m', '')
          end

          sse.write("<div class='#{text_color_class}'>#{output}</div>", event: 'message')
        end

        # Ensure the response stream and the thread are closed properly
        sse.close
        response.stream.close
      end

      # Ensure that the thread is joined when the execution is complete
      Process.wait
      output_thread.join
    rescue ConcurrentProcessRunning
      sse.write(
        "<div class='text-red-500'>Existing process running with PID: #{stored_pid}</div>",
        event: 'message'
      )
      logger.info 'Existing process running'
    rescue ActionController::Live::ClientDisconnected
      logger.info 'Client Disconnected'
    rescue IOError
      logger.info 'IOError'
    ensure
      sse.close
      response.stream.close
      release_process
    end

    # Endpoint to cancel currently running process
    def cancel
      if process_running?
        # If a process is running, get the PID and attempt to kill it
        begin
          Process.kill('TERM', stored_pid)
          sse.write(
            "<div class='text-yellow-400'>Cancelled the process with PID: #{stored_pid}</div>",
            event: 'message'
          )
          release_process
        rescue Errno::ESRCH
          sse.write(
            "<div class='text-red-500'>Process with PID #{stored_pid} is not running.</div>",
            event: 'message'
          )
        end
      else
        sse.write(
          "<div class='text-slate-400'>No process is currently running, nothing to cancel.</div>",
          event: 'message'
        )
      end
    rescue ActionController::Live::ClientDisconnected
      logger.info 'Client Disconnected'
    rescue IOError
      logger.info 'IOError'
    ensure
      sse.write(
        '[Kamal Rails] End transmission',
        event: 'message'
      )
      sse.close
      response.stream.close
      release_process
    end

    private

    def set_headers
      response.headers['Content-Type'] = 'text/event-stream'
      response.headers['Last-Modified'] = Time.now.httpdate
    end

    def sse
      @sse ||= SSE.new(response.stream, event: 'Stream Started')
    end

    def command
      params[:command]
    end

    def lock_file_path
      Rails.root.join(KamalRails::DIRECTORY, 'process.lock')
    end

    def lock_process
      File.open(lock_file_path, 'a') do |file|
        file.puts(KamalRails::CurrentExecution.child_pid)
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
  end
end

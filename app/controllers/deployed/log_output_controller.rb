module Deployed
  class LogOutputController < ApplicationController
    include ActionController::Live

    before_action :set_headers

    def index
      thread_exit_flag = false

      thread = Thread.new do
        File.open(current_log_file, 'r') do |file|
          while true
            IO.select([file])

            found_deployed = false

            file.each_line do |line|
              # Check the exit flag
              if thread_exit_flag
                break
              end

              css_class = if line.include?('[Deployed]')
                'text-slate-400'
              else
                'text-green-400'
              end
              sse.write("<div class='#{css_class}'>#{line.strip}</div>", event: 'message')

              if line.include?("[Deployed Rails] End")
                found_deployed = true
                break
              end
            end

            if found_deployed || thread_exit_flag
              break
            end
          end
        end
      end

      begin
        thread.join
      rescue ActionController::Live::ClientDisconnected
        logger.info 'Client Disconnected'
      ensure
        # Set the exit flag to true to signal the thread to exit
        thread_exit_flag = true
        sse.close
        response.stream.close
      end
    end


    private

    def set_headers
      response.headers['Content-Type'] = 'text/event-stream'
      response.headers['Last-Modified'] = Time.now.httpdate
    end

    def sse
      @sse ||= SSE.new(response.stream, event: 'Stream Started')
    end
  end
end

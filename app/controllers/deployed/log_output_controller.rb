module Deployed
  class LogOutputController < ApplicationController
    include ActionController::Live

    before_action :set_headers

    def index
      initial_log_file_size = File.size(current_log_file)

      thread = Thread.new do
        File.open(current_log_file, 'r') do |file|
          while true
            IO.select([file])

            found_deployed = false

            file.each_line do |line|
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

            if found_deployed
              break # Exit the outer loop when "[Deployed]" is found
            end
          end
        end
      end

      thread.join
    rescue ActionController::Live::ClientDisconnected
      logger.info 'Client Disconnected'
    rescue IOError
      logger.info 'IOError'
    ensure
      sse.close
      response.stream.close
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

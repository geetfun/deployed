module Deployed
  class LogOutputController < ApplicationController
    include ActionController::Live

    before_action :set_headers

    def index
      sse.write(
        "<div class='text-slate-400'>Displaying log messages</div>",
        event: 'message'
      )

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

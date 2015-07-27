class ImportController < ApplicationController
  include ActionController::Live
  def importlog
    response.headers['Content-Type'] = 'text/event-stream'
    10.times {
      response.stream.write(": starting up stream\n\n")
      response.stream.write("data: test_log\n\n")
      sleep 0.5
    }
  ensure
    response.stream.close
  end

  def experiment
  end
end

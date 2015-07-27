class HomeController < ApplicationController
  def index
  end
  def clear_sessions
    reset_session
    render :text => 'clear sessions'
  end
end

class HomeController < ApplicationController
  def index
    session['lipid_count'] ||= Lipid.select("id").count
    session['compound_count'] ||= Compound.select("id").count
    session['quant_count'] ||= Quant.select("id").count
  end
  def clear_sessions
    reset_session
    render :text => 'clear sessions'
  end
  def download_slim
    send_file("/srv/GT/analysis/masaomi/slim/proto-slim2-dev/public/slim-v0.0.1.tgz")
  end
end

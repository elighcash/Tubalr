class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :ensure_domain

  APP_DOMAIN = 'www.tubalr.com'

  def ensure_domain
    if Rails.env.production? && request.env['HTTP_HOST'] != APP_DOMAIN
      redirect_to "http://#{APP_DOMAIN}#{request.env['REQUEST_PATH']}", :status => 301
    end
  end
  
  def index
    render :layout => "application", :template => "index"
  end
  
  def player
    Searches.create({  
      :search_type  => params[:search_type],
      :what         => params[:search],
      :who          => request.remote_ip
    })
    
    render :template => "player", :layout => false
  end
  
  def history
    @history    = []
    tmp_history = Searches.find(:all, :limit => 500, :order => "created_at DESC")
    
    tmp_history.each do | search |
      #if !@history.has_key?(search.what)
        @history << {
          :what => search.what.gsub("+"," "),
          :date => search.created_at.strftime("%D"),
          :type => search.search_type,
          :url  => "/#{search.search_type}/#{search.what.gsub(" ","+")}",
          :who  => search.who
        }
      #end
    end
    
    render :layout => "application", :template => "history"
  end
end

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :search_tags
  
  def search_tags
    @search_tags = session[:tags] 
    @search_tags
  end

  def add_search_tag(tag)
    session[:tags] ||= []
    session[:tags] << tag
    session[:tags].uniq!
  end

  def remove_search_tag(tag)
   session[:tags].delete(tag)
  end

  def clear_search_tag
    session[:tags] = nil
    @search_tags = nil
  end
end

class ApplicationController < ActionController::Base
  include LocalizedSystem
  
  protect_from_forgery
  
  helper_method :current_user
  before_filter :authenticate, :hourly_update_rate_limit_status

  def authentication_required
    redirect_to root_url, :notice => t('sessions.authentication_required') unless current_user
  end
  
  def paginate(model, per=10)
    @page = params[:page]
    model.page(@page).per(per)
  end

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def authenticate
    current_user.authenticate if current_user
  end
  
  def hourly_update_rate_limit_status
    if current_user && current_user.rate_limit_status != 350 && current_user.updated_at + 1.hour < Time.zone.now
      current_user.update_rate_limit_status
    end
  end
end

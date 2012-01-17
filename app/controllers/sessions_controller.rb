class SessionsController < InheritedResources::Base
  
  def create
	  omniauth = request.env["omniauth.auth"]
	  user = User.find_by_uid(omniauth['uid'])
	  if user || current_user
			flash[:success] = t('sessions.signed_in')
      session[:user_id] = user.id
	  else
			user = User.create_from_omniauth(omniauth)
	    if user
				flash[:success] = t('sessions.account_created')
        session[:user_id] = user.id
			else
			  flash[:error] = t('sessions.failure')
			end
	  end
	  user.update_rate_limit_status
	  redirect_to root_url
	end
  
  def destroy
	 session[:user_id] = nil
	 flash[:success] = t('sessions.signed_out')
	 redirect_to root_url
  end
  
  
	def failure
		flash[:error] = t('sessions.failure')
		redirect_to root_url
	end
end
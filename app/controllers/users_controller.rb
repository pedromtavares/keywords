class UsersController < InheritedResources::Base
	def show
	  super
	end
	
	def update
    update!(:notice => t('users.updated'))
  end
	
	def destroy
	  current_user.destroy
	  session[:user_id] = nil
	  flash[:success] = t('users.deleted')
	  redirect_to root_url
	end
	
	private
	
	def resource
	  current_user
	end
end
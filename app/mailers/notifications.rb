class Notifications < ActionMailer::Base
    
	default :from => 'universitasproject@gmail.com'
	
	def search_finished(user_id, search_id)
	  @user = User.find(user_id)
	  @search = Search.find(search_id)
		mail(:to => "#{@user.name} <#{@user.email}>", :subject => "Your Search Finished!")
	end
	
end

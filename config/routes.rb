Keywords::Application.routes.draw do
  resource :user
  resource :sessions, :only => [:create, :destroy] do
    member do
      get :failure
    end
  end
  
  resources :searches do
    member do
      post :restart
      post :repeat
      post :follow
    end
  end
  
  resources :twitter_users do
    member do
      post :follow
      delete :unfollow
    end
  end
  
  resource :about, :only => [:show, :create], :controller => 'about'

  root :to => 'home#show'
  match '/auth/twitter/callback' => 'sessions#create'
	match '/auth/failure' => 'sessions#failure'
end

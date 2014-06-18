Qaror::Application.routes.draw do

  resources :pages

  #
  # admin
  #
  namespace :admin do
    root :to => "main#index"
    resources :main do
      collection do
        get 'thrs'
        get 'ans'
        get 'comments'
      end
    end
    resources :activities do
      collection do
        get 'reported'
      end
    end
    resources :pages
    resources :stats
    resources :badges
    resources :users
    resources :contact_us
  end

  match '/auth/:provider/callback' => 'login#create'
  match '/auth/failure' => 'login#failure'

  resources :search do
    collection do
      get 'tags'
    end
  end

  resources :achievements, :path => "/achievements"

  resources :comments
  match '/comments/:id/vote/:vote',:to=>'comments#vote', :as => :vote_comments

  resources :tags
  match '/tags/sort/:sort', :to => 'tags#index', :as => :tags_sort
  match '/tags/:id/:sort', :to => 'tags#show', :as => :tag_sort

  resources :ans, :path => "/answers" do
    resources :comments

    member do
      put 'edit'
      get 'report_flag'
      put 'flag'
      get 'history'
    end
  end

  match '/answers/:id/resolved' => 'ans#resolved', :as => :resolved_an
  match '/answers/:id/unresolved' => 'ans#unresolved', :as => :unresolved_an
  match '/answers/:id/vote/:vote',:to=>'ans#vote', :as => :vote_ans

  match '/questions/:id/sort/:sort',:to=>'thrs#show', :as => :ans_sort


  resources :thrs, :path => "/questions" do
    resources :comments
    member do
      put 'edit'
      get 'fav'
      get 'report_close'
      get 'report_flag'
      post 'answer'
      put 'close'
      put 'flag'
      put 'reopen'
      put 'subscribe'
      get 'history'
    end
  end
  match '/questions/:id/vote/:vote',:to=>'thrs#vote', :as => :vote_thrs
  match '/questions/sort/:sort', :to => 'thrs#index', :as => :thrs_sort

  resources :login

  match '/users/profile', :to=> 'users#update', :via => :put
  match '/users/profile', :to=> 'users#edit', :via => :get, :as=>:profile
  resources :users, :path => "/users" do
    collection do
      get 'activate'
      get 'remind_password_edit'
      post 'remind_password'
      get 'change_password'
      post 'change_password'
      get 'ako'
    end
    member do
      get 'send_activation_link'
      get 'activity'
      get 'reputation'
      get 'votes'
      get 'favorites'
    end
  end

  match '/contact' => 'main#pages', :as => :contact_us
  match '/faq' => 'main#pages', :as => :faq
  match '/privacy' => 'main#pages', :as => :privacy
  match '/privileges' => 'pages#privileges', :as => :privileges
  
  match '/remind_password', :to => 'users#remind_password_edit',:as=>:remind_password_edit_users
  match '/register', :to => 'users#new',:as => :register
  match '/login', :to => 'login#index',:as => :login
  match '/logout', :to => 'login#logout',:as => :logout
#  match '/wp', :to=> 'main#wiki_parser', :as=>:wiki_parser
  root :to => 'thrs#index'

end

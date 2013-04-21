CodeRails3::Application.routes.draw do

  root :to => 'dashboard#index'
  match '' => 'dashboard#index', :as => 'dashboard'
  match '/help' => 'dashboard#help', :as => 'help'
  match '/force_exception' => 'application#force_exception'

  match '/login' => 'sessions#new', :as => 'login'
  match '/force_login' => 'sessions#create', :as => 'force_login'
  match '/logout' => 'sessions#destroy', :as => 'logout'
  match '/auth/cas/callback' => 'sessions#create'
  match '/auth/failure' => 'sessions#failure'

  match '/repository_directory' => 'repository_directory#index', :as => 'repository_directory'
  match '/repository_directory/:id' => 'repository_directory#show/:id', :as => 'repository_info'

  resource :profile, :only => [:edit, :update]

  resources :ssh_keys
  resource :invitation, :only => [:new, :create]

  resources :repositories, :except => :show do
    member do
      post :confirm_update
    end

    resources :collaborators, :except => [:new, :create, :destroy] do
      collection do
        get :edit
        post :update
        get :index
      end
    end
  end

  resources :spaces do
    member do
      post :confirm_update
    end

    resources :repositories, :controller => 'space_repositories'
    resources :deploy_keys, :except => [:show, :edit, :update], :controller => 'space_deploy_keys'
    resources :owners, :except => [:new, :create, :destroy], :controller => 'space_owners' do
      collection do
        get :edit
        post :update
        get :index
      end
    end
  end


  ###############################################################################
  ## Admin Routes
  ###############################################################################
  match '/admin' => 'admin/home#index', :as => 'admin_root'
  match '/admin' => 'admin/home#index', :as => 'admin'

  match '/admin/ldap_search' => 'admin/ldap_search# index', :as => 'admin_ldap_search'
  match '/admin/ldap_search/do_search' => 'admin/ldap_search#do_search', :as => 'admin_do_ldap_search'

  namespace(:admin) do
    resources :users, :except => :show do
      member do
        get :login
      end

      resources :ssh_keys, :except => :show
      resources :collaborations, :only => [:index], :as => 'permissions', :controller => 'user_permissions'
    end

    resources :spaces do
      resources :repositories, :controller => 'space_repositories'
      resources :owners, :except => [:new, :create, :destroy], :controller => 'space_owners' do
        collection do
          get :edit
          post :update
          get :index
        end
      end
      resources :deploy_keys, :controller => 'space_deploy_keys', :except => 'show' do
        resources :collaborations, :only => [:index], :as => 'permissions', :controller => 'user_permissions'
      end
    end

    resources :repositories, :except => :show do
      member do
        get :create_svn_directory
        post :confirm_update
      end

      resources :collaborators, :except => [:new, :create, :destroy], :controller => 'collaborators' do
        collection do
          get :edit
          post :update
          get :index
        end
      end
    end
  end

  namespace :api do
    resources :repositories
  end

  scope "api" do
    match '/ldap_search' => 'api/ldap_search#find'
    match '/person_search' => 'api/ldap_search#person_search', :as => :ldap_person_search
    match '/base/test_auth' => 'api/base#test_auth'
    match '/web_data_loader/:action' => 'api/web_data_loader#:action'
    #match '/user_stats/:action/:username' => "api/user_stats#:action",
    #              :requirements => { :username => %r([^/;,?]+) }
    match '/repository_stats/:action/:space_name/:repo_name' => 'api/repository_stats#:action'
  end

  match '/cron_jobs/send_email' => 'cron_jobs#send_email'
  match '/cron_jobs/transition_search_plans' => 'cron_jobs#transition_search_plans'
end

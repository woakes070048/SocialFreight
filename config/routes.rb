Socialfreight::Application.routes.draw do

  get "logout" => "sessions#destroy", :as => "logout"
  get "login"  => "sessions#new", :as => "login"
  get "signup" => "users#new", :as => "signup"
  get "try"    => "patrons#new", :as => "try"
  #get "today" => "home#today", :as => "today"
  #get "today" => "home#egitim", :as => "egitim"
  get "dashboard" => "dashboard#index", :as => "dashboard"
  get "calendar"  => "dashboard#calendar", :as => "calendar"

  resources :users do
    member do
      get :activate, :activation, :follow
    end
    collection do
      get :invite_coworkers
    end
    collection do
      put  :create_coworkers
    end
  end
  resources :sessions
  resources :password_resets
  resources :betausers

  resources :patrons
  resources :operations do
    member do
      get :home, :select
    end
  end
  resources :places
  resources :companies do
    resources :posts
  end
  resources :partners
  resources :contacts
  resources :events
  resources :finunits
  resources :findocs
  resources :invoitems
  
  resources :branches
  resources :people
  resources :positions do
    resources :posts
    member do
      get :addload
      get :plan
    end
  end
  resources :transports do
    resources :posts
  end
  resources :transroutes

  resources :loadings do
    resources :posts
    member do
      get :addtoplan
      get :plan
    end
  end
  resources :departures do
    resources :posts
  end
  resources :arrivals do
    resources :posts
  end
  resources :packages
  resources :containers
  resources :transnodes
  resources :connects

  resources :rentals do
    resources :posts
  end
  resources :vehicles do
    resources :posts
  end
  resources :vessels
  resources :documents do
    resources :posts
  end
  resources :costs
  resources :payoffs
  resources :payments
  resources :fuels

  resources :listheaders do
    resources :listitems
  end

  resources :searches do
    member do
      get :planning
    end
  end

  resources :countries
  resources :cities
  resources :currencies
  resources :banks
  resources :feedbacks
  resources :posts do
    resources :comments
  end
  resources :todolists do
    resources :tasks
  end
  resources :reminders
  resources :activities
  resources :nicks
  resources :junks

  resources :setup
  resources :reservation
  resources :transplan
  resources :operation_wizard
  resources :payback
  
  get "air" => "home#air", :as => "air"
  get "sea" => "home#sea", :as => "sea"
  get "road" => "home#road", :as => "road"
  get "rail" => "home#rail", :as => "rail"
  get "inland" => "home#inland", :as => "inland"

  %w[roadmap security features services aboutus].each do |page|
    get page, controller: "home", action: page
  end

  get "crm" => "companies#home"
  get "finance" => "findocs#home"
  get "fleetman" => "vehicles#home"

  root :to => 'home#index'

  mount Resque::Server, at: "/resque"
  mount Blogger::Engine, at: "/blog"
  mount Assetim::Engine, at: "/assetim"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end

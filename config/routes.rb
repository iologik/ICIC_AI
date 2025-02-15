# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount LetsencryptPlugin::Engine, at: '/' # It must be at root level

  authenticate :admin_user, ->(u) { u.admin? } do
    mount Sidekiq::Web, at: 'sidekiq'
  end

  root to: 'home#index'
  get  '/about', to: 'home#about', as: :about
  get  '/contact', to: 'home#contact', as: :contact
  post '/contact', to: 'home#handle_contact'

  get '/login_as/:id' => 'application#login_as'

  devise_for :admin_users, ActiveAdmin::Devise.config

  get '/admin/payments/:id/transfer' => 'admin/payment#transfer', :as => :transfer_admin_payment_path

  begin
    begin
      ActiveAdmin.routes(self)
    rescue
      ActiveAdmin::DatabaseHitDuringLoad
    end
  end

  get '/mail_test' => 'application#mail_test'
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

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end

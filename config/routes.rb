Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "reports/top_clients", to: "reports#top_clients", as: :reports_top_clients
  get "reports/revenue", to: "reports#revenue", as: :reports_revenue
  get "reports/active_rentals", to: "reports#active_rentals", as: :reports_active_rentals


  resources :scooters
  resources :clients
  resources :rentals
  root "scooters#index"

  resources :backups, only: [:index, :create, :destroy], constraints: { id: /[^\/]+/ } do
    collection do
      post :upload
    end
    member do
      get :download
      post :restore
    end
  end

  resources :storage_mode, only: [:index] do
    collection do
      post :switch_to_file
      post :switch_to_database
      post :create_backup_from_file
      post :restore_from_file_backup
    end
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end

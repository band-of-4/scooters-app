Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "reports/top_clients", to: "reports#top_clients", as: :reports_top_clients
  get "reports/revenue", to: "reports#revenue", as: :reports_revenue
  get "reports/active_rentals", to: "reports#active_rentals", as: :reports_active_rentals

  post 'scooters/undo', to: 'scooters#undo', as: :undo_scooters
  post 'scooters/redo', to: 'scooters#redo', as: :redo_scooters
  resources :scooters

  post 'clients/undo', to: 'clients#undo', as: :undo_clients
  post 'clients/redo', to: 'clients#redo', as: :redo_clients
  resources :clients

  post 'rentals/undo', to: 'rentals#undo', as: :undo_rentals
  post 'rentals/redo', to: 'rentals#redo', as: :redo_rentals
  resources :rentals

  root to: redirect('/scooters')

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end

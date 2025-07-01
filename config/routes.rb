Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  resource :session
  # resources :passwords, param: :token

  # nest transactions resources under merchants
  resources :merchant, only: [ :index, :show, :edit, :update, :destroy ] do
    scope module: :merchant do
      # use uuid instead of id for transactions
      resources :transaction, only: [ :show ], param: :uuid
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.slim)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"

  scope :api, module: "api" do
    scope :v1, module: "v1" do
      resources :session, only: [ :create, :index ]
      resources :transaction, only: [ :create ]
    end
  end

  if Rails.env.development?
    require "sidekiq/web"
    mount Sidekiq::Web => "/sidekiq"
  end
end

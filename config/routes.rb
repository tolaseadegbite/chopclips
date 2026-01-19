Rails.application.routes.draw do
  get  "sign_in", to: "sessions#new"
  post "sign_in", to: "sessions#create"
  get  "sign_up", to: "registrations#new"
  post "sign_up", to: "registrations#create"
  resources :sessions, only: [ :index, :show, :destroy ]
  resource  :password, only: [ :edit, :update ]
  namespace :identity do
    resource :email,              only: [ :edit, :update ]
    resource :name,               only: [ :edit, :update ]
    resource :email_verification, only: [ :show, :create ]
    resource :password_reset,     only: [ :new, :edit, :create, :update ]
  end
  namespace :authentications do
    resources :events, only: :index
  end
  get  "/auth/failure",            to: "sessions/omniauth#failure"
  get  "/auth/:provider/callback", to: "sessions/omniauth#create"
  post "/auth/:provider/callback", to: "sessions/omniauth#create"
  post "users/:user_id/masquerade", to: "masquerades#create", as: :user_masquerade
  resource :invitation, only: [ :new, :create ]
  namespace :sessions do
    resource :passwordless, only: [ :new, :edit, :create ]
    resource :sudo, only: [ :new, :create ]
  end
  root "home#index"
  get "static_pages/pricing"
  get "static_pages/privacy"
  get "static_pages/support"
  get "static_pages/tos"
  get "static_pages/privacy_policy"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # 1. For Admins: Sending invites from the dashboard
  resources :invitations, only: [ :create, :destroy ]

  # 2. For Recipients: Clicking the email link
  # Using a singular resource because you accept ONE specific invite
  resource :invitation_acceptance, only: [ :show, :update ]

  resources :accounts

  # Account switcher
  post "accounts/:id/switch", to: "accounts#switch", as: :switch_account

  # root "projects#index"

  # Defines the root path route ("/")
  # root "posts#index"

  resource :dashboard, only: [ :show ]
  get "/settings", to: "home#index"
end

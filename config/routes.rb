RealtimeVote::Application.routes.draw do
  root to: 'vote#index'
  resources :rooms, only: [:index, :update]
  resources :sessions, only: [:create, :destroy]
  resources :proposals, only: [:index, :create, :update]
  resources :users, only: [:update]
  resources :groups, only: [:update]
end

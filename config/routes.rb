RealtimeVote::Application.routes.draw do
  root to: 'vote#index'
  resources :rooms, only: [:index, :update]
  resources :sessions, only: [:create, :destroy]
  resources :proposals, only: [:index, :create, :update]
  resources :users, only: [:create, :update]
  resources :groups, only: [:update]

  get 'admin/' => 'admin#index'
  get 'admin/show_users' => 'admin#show_users'
  get 'admin/show_groups' => 'admin#show_groups'
  get 'admin/show_proposals' => 'admin#show_proposals'

end

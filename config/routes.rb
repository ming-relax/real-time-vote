RealtimeVote::Application.routes.draw do
  root to: 'vote#index'
  get '/login' => 'vote#login'
  
  resources :sessions, only: [:create, :destroy]
  resources :proposals, only: [:index, :create, :update]
  resources :users, only: [:create, :update]
  get 'users/query/:id' => 'users#query'

  
  get 'group/index' => 'groups#index'
  put 'groups/:id/next_round' => 'groups#next_round'

  get 'admin/' => 'admin#index'
  get 'admin/show_users' => 'admin#show_users'
  get 'admin/show_groups' => 'admin#show_groups'
  get 'admin/show_proposals' => 'admin#show_proposals'

  # proposal
  post 'proposals/submit' => 'proposals#submit'
  put 'proposals/accept/:id' => 'proposals#accept'

  # room
  get 'rooms/' => 'rooms#index'
  get 'rooms/template' => 'rooms#template'
  put 'rooms/join' => 'rooms#join'
  put 'rooms/leave' => 'rooms#leave'

end

RealtimeVote::Application.routes.draw do
  root to: 'users#new'

  get '/login' => 'sessions#new'

  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'

  resources :users, only: [:create, :update]

  get 'admin/' => 'admin#index'
  get 'admin/show_users' => 'admin#show_users'
  get 'admin/show_groups' => 'admin#show_groups'
  get 'admin/show_proposals' => 'admin#show_proposals'

  get 'vote/index' => 'vote#index'

  # rest api
  get '/vote/users/query/:id' => 'users#query'
  
  scope 'vote', module: 'api' do
    get 'group/index' => 'groups#index'
    put 'groups/:id/next_round' => 'groups#next_round'

    # proposal
    post 'proposals/submit' => 'proposals#submit'
    put 'proposals/accept/:id' => 'proposals#accept'

    # room
    get '/vote/rooms/' => 'rooms#index'
    get '/vote/rooms/template' => 'rooms#template'
    put '/vote/rooms/join' => 'rooms#join'
    put '/vote/rooms/leave' => 'rooms#leave'
    
  end

end

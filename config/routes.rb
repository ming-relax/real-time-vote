RealtimeVote::Application.routes.draw do
  require 'sidekiq/web'
  require 'sidetiq/web'
  mount Sidekiq::Web => '/sidekiq'

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
    get '/rooms' => 'rooms#index'
    get '/rooms/template' => 'rooms#template'
    put '/rooms/join' => 'rooms#join'
    put '/rooms/leave' => 'rooms#leave'
    
  end

end

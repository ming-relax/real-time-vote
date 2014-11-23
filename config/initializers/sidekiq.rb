Sidekiq.configure_server do |config|
  config.redis = { :url => ENV['REDIS_1_PORT_6379_TCP'], :namespace => 'sidekiq' }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => ENV['REDIS_1_PORT_6379_TCP'], :namespace => 'sidekiq' }
end
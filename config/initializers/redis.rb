require 'redis'

$redis = Redis.new(:url => ENV['REDIS_PORT_6379_TCP'])

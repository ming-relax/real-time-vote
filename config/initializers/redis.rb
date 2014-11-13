require 'redis'

$redis = Redis.new(:url => ENV['REDIS_1_PORT_6379_TCP'])

require 'resque'
Resque.redis = Redis.new(host: '127.0.0.1', port: ENV['BOXEN_REDIS_PORT'] || '6379', namespace: 'noshare')

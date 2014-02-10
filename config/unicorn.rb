unless ENV['BOXEN_SOCKET_DIR'].nil?
  worker_processes 2
  listen "#{ENV['BOXEN_SOCKET_DIR']}/noshare", :backlog => 1024
  timeout 120
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

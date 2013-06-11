worker_processes Integer(ENV['WEB_CONCURRENCY'] || 2)
timeout Integer(30)
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  Sidekiq.configure_client do |config|
    config.redis = { size: 2 } # for web dyno
  end
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
  end

  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection

  Sidekiq.configure_client do |config|
    config.redis = { size: 2 } # for web dyno
  end
end

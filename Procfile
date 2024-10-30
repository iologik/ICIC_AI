web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb 
release: rake db:migrate
worker: bundle exec sidekiq -c 10 -q default -q mailers 
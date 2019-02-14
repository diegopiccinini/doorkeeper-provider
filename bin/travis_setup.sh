cp config/samples/database.yml config/database.yml
cp .env.sample .env
cp .env.sample .env.test
RAILS_ENV=test bundle exec rails db:create
RAILS_ENV=test bundle exec rails db:migrate
RAILS_ENV=test bundle exec rake test


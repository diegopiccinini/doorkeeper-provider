ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'database_cleaner'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.

  DatabaseCleaner.strategy = :truncation

  DatabaseCleaner.clean

  fixtures :all

  # Add more helper methods to be used by all tests here...
end

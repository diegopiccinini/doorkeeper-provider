ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'database_cleaner'
require 'webmock/minitest'
require 'sucker_punch/testing/inline'

class ActiveSupport::TestCase

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  module FixtureFileHelpers
    def back_uri subdomain
      "https://#{subdomain}.#{ENV['CUSTOM_DOMAIN_FILTER'].split.first}#{ENV['BACKEND_CALLBACK_URI_PATH']}"
    end
    def front_uri subdomain, str
      "https://#{subdomain}.#{ENV['CUSTOM_DOMAIN_FILTER'].split.first}#{ENV['FRONTEND_CALLBACK_URI_PATH']}/#{str}"
    end
  end

  ActiveRecord::FixtureSet.context_class.include FixtureFileHelpers

  DatabaseCleaner.strategy = :truncation

  DatabaseCleaner.clean

  fixtures :all

  # Add more helper methods to be used by all tests here...
end

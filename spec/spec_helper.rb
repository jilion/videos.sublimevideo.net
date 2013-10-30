ENV["RAILS_ENV"] ||= 'test'

require_relative "../config/environment"
require 'rspec/rails'
require 'shoulda-matchers'
require 'factory_girl_rails'

Dir[Rails.root.join('spec/config/**/*.rb')].each { |f| require f }
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.check_pending!

RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = true
  config.use_transactional_fixtures = true
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

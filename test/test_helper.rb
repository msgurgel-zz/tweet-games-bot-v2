# Setup Minitest
require "minitest/autorun"
require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

# Setup connection to test database
require 'active_record'
db_config = YAML.load_file('db/config.yml')
ActiveRecord::Base.establish_connection(db_config["test"])
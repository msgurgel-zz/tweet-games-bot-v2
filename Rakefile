require 'rake/testtask'
require 'tasks/standalone_migrations'

# Set database configurations based on environment
StandaloneMigrations::Configurator.environments_config do |env|
    env.on "production" do
      if (ENV['DATABASE_URL']) # DATABASE_URL env var will be set in Heroku
        db = URI.parse(ENV['DATABASE_URL'])
        return {
          :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
          :host     => db.host,
          :username => db.user,
          :password => db.password,
          :database => db.path[1..-1],
          :encoding => 'utf8'
        }
      end

      nil
    end
end

desc 'Run tests'
task :test do
    # Prepare database
    Rails.env = ENV['RAILS_ENV']= 'test'
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:schema:load'].invoke
    Rake::Task['db:seed'].invoke
    ActiveRecord::Base.establish_connection(:test)
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:setup'].invoke
    Rake::Task['db:fixtures:load'].invoke

    # Run the tests!
    Rake::Task['test_task'].invoke
end

desc 'Run tests with no prep (to prep before running test, use rake test)'
Rake::TestTask.new do |task|
    task.test_files = FileList['test/**/test_*.rb']
    task.verbose = true
    task.name = 'test_task'
end

desc 'Run the tweet-bot'
task :run do
    Rails.env = ENV['RAILS_ENV']
    Rake::Task['db:create'].invoke
    Rake::Task['db:schema:load'].invoke
    ruby 'app/main.rb'
end
task default: "run"

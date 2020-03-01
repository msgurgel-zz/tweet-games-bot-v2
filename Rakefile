require 'rake/testtask'
require 'standalone_migrations'
StandaloneMigrations::Tasks.load_tasks

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
Rake::TestTask.new do |task|
    task.test_files = FileList['test/**/test_*.rb']
end

desc 'Run the tweet-bot'
task :run do
    ruby 'app/main.rb'
end
task default: "run"


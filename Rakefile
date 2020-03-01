require 'rake/testtask'

# Setup test report style
desc 'Run tests'
Rake::TestTask.new do |task|
    task.test_files = FileList['test/**/test_*.rb']
end

desc 'Run the tweet-bot'
task :run do
    ruby 'app/main.rb'
end
task default: "run"
require 'rake/testtask'

# Setup test report style
Rake::TestTask.new do |task|
#     # task.pattern = 'app/test/**/test*.rb'
    task.test_files = FileList['app/test/**/test_*.rb']
end
desc 'Run tests'

task :run do
    ruby 'app/main.rb'
end
desc 'Run the tweet-bot'
task default: "run"
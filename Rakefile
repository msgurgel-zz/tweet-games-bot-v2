require 'rake/testtask'

# Setup test report style
Rake::TestTask.new do |task|
#     # task.pattern = 'app/test/**/test*.rb'
    task.test_files = FileList['app/test/**/test_*.rb']
end
desc 'Run tests'

task default: "test"
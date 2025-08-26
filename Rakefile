require './lib/task_common.rb'

if File.exist?(File.expand_path("~/.env"))
  vars = File.read(File.expand_path("~/.env"))
  vars.split("\n").each do |var|
    k,v = var.split("=", 2)
    ENV[k] = v
  end
end

Dir.glob('*/**/*.rake') do |f|
  ns = File.dirname(f.to_s).gsub('/', ':')
 
  namespace ns do
    load(f)
  end
end

task :build_all_docker do
  builds = Rake.application.tasks.filter_map do |task|
    task.name if task.name =~ /build_and_push_docker/
  end.to_a

  builds.each do |build|
    Rake::Task[build].invoke
  end
end

task :dump_tasks do
  pp Rake.application.tasks
end

task :brew do
  sh "brew bundle"
end

task :k9s => "talos:setup" do
  exec "k9s"
end

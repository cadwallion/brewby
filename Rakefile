PROJECTS = %w{brewby-core}

task :default => :spec


task :spec do
  errors = []
  PROJECTS.each do |project|
    system(%(cd #{project} && #{$0} spec)) || errors << project
  end
  fail("Errors in #{errors.join(', ')}") unless errors.empty?
end

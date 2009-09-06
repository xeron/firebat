require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'core/irc'


desc "Install core databases"
task [:install,:core] do
  
  begin
    Install.migrate :up
  rescue Exception => e 
    puts e.to_s
  end
  
end

task [:install,:modules] do
  
  Dir.foreach("modules") do |file|
    if file =~ /^(.+)\.rb$/
      mod = $1
      begin
        load 'modules/' + file
      rescue => ex
        puts "Error load module #{mod}: " + ex.to_s
      end
      
      klass = eval(mod.camelize)
      
      if klass.respond_to? :install
        puts "Installing #{klass}"
        begin
          klass.install
        rescue Exception => e 
          puts e.to_s
        end
      end
      
    end
  end
  
end

# task [:convert,:modules] do
#   Dir.foreach("modules") do |file|
#     next if file !~ /\.rb$/
#     s = File.open("modules/" + file) do |f|
#       f.read
#     end
#     
#     File.open("modules/" + file,'w') do |f|
#       f.write(s)
#     end     
#   end
# end
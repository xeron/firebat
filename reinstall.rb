require 'core/schema'

puts 'drop old tables'

begin
  Install.migrate :down
rescue Exception => e 
  puts e.to_s
end

puts 'make new tables'

begin
  Install.migrate :up
rescue Exception => e 
  puts e.to_s
end
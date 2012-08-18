require 'rake'

$:.unshift File.dirname(__FILE__)
require 'core/irc'
include FireBat

namespace :db do

  desc "Install core tables"
  task [:install, :core] do
    begin
      Install.migrate :up
    rescue Exception => e
      puts e.to_s
    end
  end

  desc "Install modules tables"
  task [:install, :modules] do
    Dir.foreach("modules") do |file|
      if file =~ /^(.+)\.rb$/
        mod = $1
        begin
          load File.join("modules", file)
        rescue => ex
          puts "Error loading module #{mod}: " + ex.to_s
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

end

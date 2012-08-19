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

  desc "Dump data from DB to Marshal."
  task [:dump] do
    Dir.foreach("modules") do |file|
      if file =~ /^(.+)\.rb$/
        mod = $1
        begin
          load File.join("modules", file)
        rescue => ex
          puts "Error loading module #{mod}: " + ex.to_s
        end
      end
    end

    [ RmudItemCommand::RmudItem,
      SowAdditemCommand::SowItem,
      QuoteCommand::Quote,
      BorCommand::Borquote,
      FireBatCommand::User,
      FireBatCommand::Role,
      FireBatCommand::RolesUser
    ].each do |klass|
      File.open(klass.name, 'wb') do |file|
        Marshal.dump(klass.all, file)
      end
    end
  end

  desc "Load data from Marshal to DB."
  task [:load] do
    ActiveRecord::Base.partial_updates = false
    Dir.foreach("modules") do |file|
      if file =~ /^(.+)\.rb$/
        mod = $1
        begin
          load File.join("modules", file)
        rescue => ex
          puts "Error loading module #{mod}: " + ex.to_s
        end
      end
    end

    [ RmudItemCommand::RmudItem,
      SowAdditemCommand::SowItem,
      QuoteCommand::Quote,
      BorCommand::Borquote,
      FireBatCommand::User,
      FireBatCommand::Role,
      FireBatCommand::RolesUser
    ].each do |klass|
      File.open(klass.name, 'r') do |file|
        data = Marshal.load(file)
        data.each do |item|
          item.instance_variable_set(:@new_record, true)
          item.save!
        end
      end
    end
  end

end

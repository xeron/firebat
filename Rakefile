require 'rake'

$:.unshift File.dirname(__FILE__)
require 'core/irc'
include FireBat

def load_modules
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
end

namespace :db do

  namespace :install do

    desc "Install core tables"
    task :core do
      begin
        Install.migrate :up
      rescue Exception => e
        puts e.to_s
      end
    end

    desc "Install modules tables"
    task :modules do
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

  desc "Move data from mysql to postgresql."
  task :dump do
    load_modules

    establish_connection ({
      :adapter  => "mysql2",
      :host     => "localhost",
      :username => "root",
      :password => "",
      :database => "rmudbot"
    })

    [ RmudItemCommand::RmudItem,
      SowAdditemCommand::SowItem,
      QuoteCommand::Quote,
      BorCommand::Borquote,
      FireBatCommand::User,
      FireBatCommand::Role,
      FireBatCommand::RolesUser
    ].each do |klass|
      File.open(klass.name, 'wb') do |file|
        Marshal.dump(klass.all.to_a, file)
      end
    end
  end

  desc "Fix postgresql sequences."
  task :fix_pg_seq do
    load_modules

    { RmudItemCommand::RmudItem => "rmud_items_id_seq",
      SowAdditemCommand::SowItem => "sow_items_id_seq",
      QuoteCommand::Quote => "quotes_id_seq",
      BorCommand::Borquote => "borquotes_id_seq",
      FireBatCommand::User => "users_id_seq",
      FireBatCommand::Role => "roles_id_seq"
    }.each_pair do |klass, seq|
      ActiveRecord::Base.connection.execute("ALTER SEQUENCE #{seq} RESTART WITH #{klass.last.id + 1};")
    end
  end

end

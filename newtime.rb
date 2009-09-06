require 'rubygems'
require 'pp'
require_gem 'activerecord'
ActiveRecord::Base.establish_connection(:adapter => 'mysql', :database => 'rmudbot',
    :username => 'root', :password => '', :host => 'localhost')


class Update1 < ActiveRecord::Migration
  def self.up
    add_column :items, :time2, :datetime
  end
  def self.down
    remove_column :items, :time2
  end
end

class Update2 < ActiveRecord::Migration
  def self.up
    remove_column :items, :time
    rename_column :items, :time2, :time
  end
end

puts "add new column..."
Update1.migrate(:up)

class Item < ActiveRecord::Base
end

puts "finding all..."
items = Item.find(:all)
puts "converting..."
items.each do |i|
  i.time2 = Time.at(i.time)
  i.save
  puts "#{i.id} from type #{i.time.class} to #{i.time2.class} => #{i.time} ->  #{i.time2}"
end
puts "rename & remove..."
Update2.migrate(:up)
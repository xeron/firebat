class RmudItemCommand < FireBatCommand

  def on_privmsg( cmd )
    text = cmd.args_tail(1,1)
	 if text =~ /^(\S) (.+)$/
	   keys = {"н" => "name","с" => "prop","т" => "tip","о" => "lim","в" => "vli","э" => "eff","з" => "spell","" => "spells","у" => "dmg","б" => "armor","п" => "S"}
	   field = keys[$1]
	   text = $2
	   @irc.privmsg cmd.reply, "Искали по полю: #{field}\n"
	 else
	   field = "name"
	 end
	 if text =~ /^(\d+)\.(.+)$/
	   n = $1.to_i - 1
	   text = $2
	 else
	   n = 0
	 end
	 if text =~ /^(.+) (\d+)-(\d+)$/
	   text = $1
	   niz = $2.to_i - 1
	   ver = $3.to_i
	 else
	   niz = 0
	   ver = 10
	 end
    text.gsub!(".","%")
    text = "%#{text}%"
	 nums = RmudItem.count(:conditions => ["#{field} like ?",text])
	 if n < 0
	   if ((niz < 0) || (ver < niz) || (niz > nums))
	     niz = 0
	     ver = 10
	   end
	   if ver > nums
	     ver = nums
	   end
	   kol = ver - niz
	   msg = "Найдено: #{nums} "
	   msg += "[#{niz+1}-#{ver}] " if nums > 0
      RmudItem.find(:all, :conditions => ["#{field} like ?",text], :limit => kol, :offset => niz).each do |i|
        msg += "[#{i.name}]"
      end
      @irc.privmsg cmd.reply, msg
    else
      if i = RmudItem.find( :first, :conditions => ["#{field} like ?",text], :offset => n )
        keys1=["Свойства","Тип","Ограничения","Влияния","Эффекты","Содержит заклинание","Заряды","Сила удара","Качество брони","Содержит","С"]
        keys2=["prop","tip","lim","vli","eff","spell","spells","dmg","armor","spell","S"]
        time = "Устарело!"
        time = "#{i.time.strftime("%d.%m.%Y (%H:%M)")}" if i.time > Time.mktime(2005)
        msg = "Название: #{i.name} [#{time}] (#{n+1}/#{nums})\n"
        for t in 0..10
          t1=keys1[t]
          t2=keys2[t]
        msg += "#{t1}: #{i[t2]}\n" unless "#{i[t2]}".empty?
        end
        msg.chomp!
        @irc.privmsg cmd.reply, msg
      else
        @irc.privmsg cmd.reply, "Item not found"
      end
    end
  end

  def privmsg_filter( cmd )
    cmd.args(1,0) == "!it"
  end

  class RmudItem < ActiveRecord::Base
  end

  class RmudItem::Install < ActiveRecord::Migration
    def self.up
      create_table :rmud_items do |t|
        t.column :name, :string, :limit => 60
        t.column :prop, :text
        t.column :lim, :text
        t.column :vli, :text
        t.column :eff, :text
        t.column :armor, :text
        t.column :content, :text
        t.column :spell, :text
        t.column :spells, :text
        t.column :dmg, :text
        t.column :tip, :text
        t.column :mater, :text
        t.column :S, :string
        t.column :time, :datetime
      end
    end
  end

  def self.install    
    unless Seen.table_exists?
      Seen::Install.migrate :up
    end
    add_index :rmud_items, :name, :name => "name", :unique => true
  end

end

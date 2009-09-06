class SeenCommand < FireBatCommand
  
  def on_join( cmd )
    if s = Seen.find_by_nick_and_host_and_ident(cmd.nick,cmd.host,cmd.ident)
      s.time = Time.now
      s.code = cmd.code
      s.param1 = cmd.args(0)
      s.param2 = cmd.args(1)
      s.save
    else
      field_names = [:nick,:ident,:host,:code]
      fields = {}
      field_names.each {|f| fields[f] = cmd.send(f)}
      seen = Seen.new(fields)
      seen.time = Time.now
      seen.param1 = cmd.args(0)
      seen.param2 = cmd.args(1)
      seen.save
    end
  end

  alias :on_part :on_join
  alias :on_quit :on_join
  alias :on_nick :on_join

  def on_privmsg( cmd )
    if cmd.args(1,1) =~ /^(.*)@(.*)$/
      ident = $1
      host = $2
      ident = ident.gsub("*","%")
      host = host.gsub("*","%")
      n = 1
      nums = Seen.count(:conditions => ["ident like ? and host like ?",ident,host])
      msg = "Искали по маске #{cmd.args(1,1)}. "
      if nums > 5
        msg += "Всего найдено: #{nums}. Последние 5 записей:\n"
      elsif nums != 0
        msg += "Найдено:\n"
      else
        msg += "Совпадений не найдено."
      end
      Seen.find(:all,:conditions => ["ident like ? and host like ?",ident,host],:limit => 5,:order => "time desc").each do |s|
        msg += "#{n}) "
	#time = "#{s.time.strftime("%H:%M (%d.%m.%Y)")}"
	time = Time.at(Time.now-s.time).getutc.format_irc
	if s.code == 'join'
          msg += "#{s.nick} (#{s.ident}@#{s.host}) зашел на канал #{s.param1} #{time} назад.\n"
	elsif s.code == 'part'
	  msg += "#{s.nick} (#{s.ident}@#{s.host}) покинул канал #{s.param1} (#{s.param2}) #{time} назад.\n"
	elsif s.code == 'quit'
          msg += "#{s.nick} (#{s.ident}@#{s.host}) покинул IRC (#{s.param1}) #{time} назад.\n"
	else
          msg += "#{s.nick} (#{s.ident}@#{s.host}) сменил ник на #{s.param1} #{time} назад.\n"
	end
	n += 1
      end
      reply cmd.nick, msg
    else
      @irc.service(WhoisService).work(cmd.args(1,1)) do |whois|
        if whois.status
	  reply cmd.nick, "#{whois.nick} (#{whois.ident}@#{whois.host}) сейчас в IRC на каналах #{whois.channels}."
	else
	   f = cmd.args(1,1)
	   f = f.gsub("*","%")
      seen = Seen.find(:first,:conditions => ["nick like ? or (param1 like ? and code='nick')",f,f],:order => "time desc")
      if seen
        nicks_chain = seen.nick
        while seen and seen.code == 'nick'
          #resolving nickchange chain
          nicks_chain += " => #{seen.param1}"
          new_seen = Seen.find(:first,:conditions => ["nick = ? and time > ?",seen.param1,seen.time],:order => "time desc")
          if new_seen
            seen = new_seen
          else
            break
          end
        end
        # just for debugging
        # reply cmd.nick, "I found event #{seen.code} signed at #{seen.time} params | #{seen.param1}, #{seen.param2} | #{nicks_chain}"
        time = Time.at(Time.now-seen.time).getutc.format_irc
        if seen.code == 'join'
          msg = "#{seen.nick} (#{seen.ident}@#{seen.host}) зашел на канал #{seen.param1} #{time} назад."
        elsif seen.code == 'part'
          msg = "#{seen.nick} (#{seen.ident}@#{seen.host}) покинул канал #{seen.param1} (#{seen.param2}) #{time} назад."
        elsif seen.code == 'quit'
          msg = "#{seen.nick} (#{seen.ident}@#{seen.host}) покинул IRC (#{seen.param1}) #{time} назад."
        else
          msg = "#{seen.nick} (#{seen.ident}@#{seen.host}) сменил ник на #{seen.param1} #{time} назад [#{nicks_chain}]."
        end
        reply cmd.nick, msg
      else
        reply cmd.nick, "Совпадений не найдено."
      end
        end
    end
    end
  end
  
  def privmsg_filter( cmd )
    cmd.args(1,0) == "!seen"
  end

  class Seen < ActiveRecord::Base
  end
  
  class Seen::Install < ActiveRecord::Migration
    def self.up
      create_table :seens do |t|
        t.column :nick,     :string, :limit => 30
        t.column :ident,    :string, :limit => 20
        t.column :host,     :string
        t.column :time,     :datetime
        t.column :code,     :string, :limit => 4
        t.column :param1,   :string
        t.column :param2,   :string
      end
    end
  end

  def self.install
    unless Seen.table_exists?
      Seen::Install.migrate :up
    end
  end

end

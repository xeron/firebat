class PkCommand < FireBatCommand
  require_roles :oper
    
  def on_privmsg( cmd )
    if cmd.args(1,1)
      msg =
      case cmd.args(1,1)
        when "+" then add( cmd.args(1,2), cmd.args_tail(1,3), cmd.nick )
        when "-" then rm( cmd.args_tail(1,2) )
        when "help" then help( cmd )
        else info( cmd.args_tail(1,1) )
      end
    else
      msg = list
    end
    @irc.privmsg cmd.reply, msg
  end
  
  def list
    msg = "Найдено: ["
    Pk.find(:all, :order => "name").each do |p|
      msg += p.name + ", "
    end
    msg.chop!
    msg.chop!
    msg += "]" 
  end
  
  def info(name)
    name = "%#{name}%"
    if p = Pk.find(:first, :conditions => ["name like ?",name])
      "Найдено: #{p.name}. Добавил: #{p.by}\nПричина: #{p.reason}"
    else
      "Не найдено (#{name})"
    end
  end

  def add(name, reason, nick)
    if p = Pk.find_by_name(name)
      p = Pk.update(p.id, {:reason => reason})
      "Причина для #{p.name} обновлена"
    else
      p = Pk.create(:name => name, :reason => reason, :by => nick)
      "#{p.name} добавлен в список жертв!"
    end
  end
  
  def rm(name)
    if p = Pk.find_by_name(name)
      p.destroy
      "#{name} удален из списка"
    else
      "Не найдено (#{name})"
    end
  end
  
  def help( cmd )
    msg = "Модуль контроля пк-листа для RMUD IRC Bot. Автор: Xeron. Синтаксис: !пк action <params>.
Actions:
!пк => Показывает пк-лист
!пк <имя> => Показывает персонажа и причину
!пк + <имя> <причина> => Добавляет в список, либо обновляет причину
!пк - <имя> => Удаляет из списка"
	 reply cmd.nick, msg
	 msg = ""
  end
  
  def privmsg_filter( cmd )
    cmd.args(1,0) == "!пк"
  end
  
  class Pk < ActiveRecord::Base
  end

  class Pk::Install < ActiveRecord::Migration
    def self.up
      create_table :pks do |t|
        t.column :by, :string, :limit => 30
        t.column :name, :string, :limit => 100
        t.column :reason, :text
      end
    end
  end

  def self.install    
    unless Seen.table_exists?
      Seen::Install.migrate :up
    end
    add_index :pks, :name, :name => "name", :unique => true
  end

end

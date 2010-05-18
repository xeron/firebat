class DekeiCommand < FireBatCommand
  
  def on_privmsg( cmd )
    if cmd.args(1,1)
      msg =
      case cmd.args(1,1)
        when "все" then full
        when "list" then list
        when "+" then add( cmd.args(1,2), cmd.args_tail(1,3), cmd.nick )
        when "-" then rm( cmd.args(1,2), cmd.args_tail(1,3) )
        when "help" then help( cmd )
        else info( cmd.args_tail(1,1) )
      end
    else
      msg = list
    end
    @irc.privmsg cmd.reply, msg
  end
  
  def full
    msg = "Найдено: [" +
    Dekei.find(:all,["items <> ''"], :order => "name").map(&:items).join(", ") +
    "]"
  end
  
  def list
    msg = "Найдено: [" +
    Dekei.find(:all,["items <> ''"], :order => "name").map(&:name).join(", ") +
    "]"
  end
  
  def info(name)
    name = "%#{name}%"
    if d = Dekei.find(:first, :conditions => ["name like ?",name])
      "Найдено: #{d.name}. Добавил: #{d.by}\nВещи: #{d.items}"
    else
      "Не найдено (#{name})"
    end
  end
  
  def add(name, items, nick)
    if d = Dekei.find_by_name(name)
      new = "#{d.items}, #{items}";
      d = Dekei.update(d.id, {:items => new})
      "Список для #{d.name} обновлен"
    else
      d = Dekei.create(:name => name, :items => items, :by => nick)
      "#{d.name} добавлен в список"
    end
  end
  
  def rm(name, item)
    if ((item !='') && (d = Dekei.find_by_name(name)))
      new = d.items
      if new.gsub!(", #{item}","")
        d = Dekei.update(d.id, {:items => new})
        "#{item} удален из списка дикеев #{name}"
      else
        "В списке для #{name} '#{item}' нет"
      end
    elsif d = Dekei.find_by_name(name)
      d.destroy
      "#{name} удален из списка"
    else
      "Не найдено (#{name})"
    end
  end
  
  def help( cmd )
    msg = "Модуль контроля дикеев для RMUD IRC Bot. Автор: Xeron. Синтаксис: !дикей action <params>.
Actions:
!дикей => Показывает список персонажей, у которых есть дикеи
!дикей все => Показывает список всех дикеев
!дикей <имя> => Показывает дикеи персонажа
!дикей + <имя> <вещи> => Добавляет в список нового персонажа, либо добавляет к имеющемуся персонажу <вещи>
!дикей - <имя> => Удаляет из списка персонажа
!дикей - <имя> <вещи> => Удаляет из списка дикеев персонажа <вещи>"
    reply cmd.nick, msg
    msg = ""
  end
  
  def privmsg_filter( cmd )
    cmd.args(1,0) =~ /^!д[ие]кей/
  end
  
  class Dekei < ActiveRecord::Base
  end

  class Dekei::Install < ActiveRecord::Migration
    def self.up
      create_table :dekeis do |t|
        t.column :by, :string, :limit => 30
        t.column :name, :string, :limit => 100
        t.column :items, :text
      end
    end
  end

  def self.install    
    unless Seen.table_exists?
      Seen::Install.migrate :up
    end
    add_index :dekeis, :name, :name => "name", :unique => true
  end

end

# coding: utf-8

class DekeiCommand < FireBatCommand

  def on_privmsg(cmd)
    if cmd.args(1, 1)
      msg = case cmd.args(1, 1)
      when "все" then full
      when "list" then list
      when "+" then add(cmd.args(1, 2), cmd.args_tail(1, 3), cmd.nick)
      when "-" then rm(cmd.args(1, 2), cmd.args_tail(1, 3))
      when "help" then help(cmd)
      else info(cmd.args_tail(1, 1))
      end
    else
      msg = list
    end
    @irc.privmsg cmd.reply, msg
  end

  def full
    "Найдено: [" + Dekei.find(:all, ["items <> ''"], :order => "name").collect(&:items).join(", ") + "]"
  end

  def list
    "Найдено: [" + Dekei.find(:all, ["items <> ''"], :order => "name").collect(&:name).join(", ") + "]"
  end

  def info(name)
    name = "%#{name}%"
    if d = Dekei.find(:first, :conditions => ["name like ?", name])
      "Найдено: #{d.name}. Добавил: #{d.by}\nВещи: #{d.items}"
    else
      "Не найдено (#{name})"
    end
  end

  def add(name, items, nick)
    if d = Dekei.find_by_name(name)
      unless items.empty?
        d.items = "#{d.items}, #{items}"
        d.items = items_cleanup(d.items)
        d.save
        "Список для #{d.name} обновлен"
      else
        "Напишите, что добавить в список #{d.name}"
      end
    else
      d = Dekei.create(:name => name, :items => items, :by => nick)
      "#{d.name} добавлен в список"
    end
  end

  def rm(name, item)
    if d = Dekei.find_by_name(name)
      unless item.empty?
        if d.items.include?(item)
          d.items = d.items.gsub(item, "")
          d.items = items_cleanup(d.items)
          d.save
          "#{item} удален из списка дикеев #{name}"
        else
          "В списке для #{name} '#{item}' нет"
        end
      else
        d.destroy
        "#{name} удален из списка"
      end
    else
      "Не найдено (#{name})"
    end
  end

  def items_cleanup(items)
    items.gsub(", ,", ",").gsub(/^, /, "").gsub(/, $/, "")
  end

  def help(cmd)
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

  def privmsg_filter(cmd)
    cmd.args(1, 0) =~ /^!д[ие]кей/
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
      add_index :dekeis, :name, :unique => true
    end
  end

  def self.install
    unless Dekei.table_exists?
      Dekei::Install.migrate :up
    end
  end

end

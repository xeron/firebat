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
    "Найдено: [" + Dekei.all.order(:name).pluck(:items).join(", ") + "]"
  end

  def list
    "Найдено: [" + Dekei.all.order(:name).pluck(:name).join(", ") + "]"
  end

  def info(name)
    if d = Dekei.where("name like ?", "%#{name}%").first
      "Найдено: #{d.name}. Добавил: #{d.by}\nВещи: #{d.items.join(", ")}"
    else
      "Не найдено имен, содержащих '#{name}'"
    end
  end

  def add(name, items, nick)
    items = items.split(/\s*,\s*/)

    if d = Dekei.find_by_name(name)
      if items.any?
        d.items += items
        d.save
        "В список для #{d.name} добавлено: [#{items.join(", ")}]"
      else
        "Напишите, что добавить в список #{d.name}"
      end
    else
      d = Dekei.create(:name => name, :items => items, :by => nick)
      "#{d.name} добавлен в список"
    end
  end

  def rm(name, items)
    items = items.split(/\s*,\s*/)

    if d = Dekei.find_by_name(name)
      if items.any?
        if (items - d.items).empty?
          d.items -= items
          d.save
          "Удалено из списка дикеев #{d.name}: [#{items.join(", ")}]"
        else
          "В списке для #{d.name} нет [#{items.join(", ")}]"
        end
      else
        d.destroy
        "#{name} удален из списка"
      end
    else
      "Не найдено (#{name})"
    end
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
    false
  end

  def privmsg_filter(cmd)
    cmd.args(1, 0) =~ /^!д[ие]кей/
  end

  class Dekei < ActiveRecord::Base
  end

  class Dekei::Install < ActiveRecord::Migration
    def self.up
      create_table :dekeis do |t|
        t.string :by, :limit => 30
        t.string :name, :limit => 100
        t.string :items, :limit => 30, array: true, default: []
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

# coding: utf-8

class SowItemCommand < FireBatCommand

  def on_privmsg(cmd)
    text = cmd.args_tail(1, 1)
    if text =~ /^(\S) (.+)$/
      keys = {
        "н" => "name",
        "т" => "tip",
        "л" => "lvl",
        "п" => "flags_pr",
        "о" => "flags_or",
        "а" => "affects",
        "в" => "weigth",
        "к" => "slot",
        "у" => "dmg",
        "з" => "spell",
        "с" => "skill",
        "м" => "modif",
        "ц" => "color"
      }
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
    text.gsub!(".", "%")
    text = "%#{text}%"
    nums = SowItem.where("#{field} like ?", text).count
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
      SowItem.where("#{field} like ?", text).limit(kol).offset(niz).each do |i|
        msg += "[#{i.name}]"
      end
      @irc.privmsg cmd.reply, msg
    else
      if i = SowItem.where("#{field} like ?", text).offset(n).first
        keys1 = [
          "Требует для использования",
          "Флаги предмета",
          "Флаги оружия  ",
          "Флаги запрета ",
          "Аффекты       ",
          "Вес",
          "Вы можете одеть это на",
          "Цвет",
          "Оружейное умение",
          "Повреждения",
          "Заклинание",
          "Умение",
          "Модификаторы"
        ]
        keys2 = [
          "lvl",
          "flags_pr",
          "flags_or",
          "flags_zap",
          "affects",
          "weigth",
          "slot",
          "color",
          "wp_skill",
          "dmg",
          "spell",
          "skill",
          "modif"
        ]
        time = "Устарело!"
        time = "#{i.time.strftime("%d.%m.%Y (%H:%M)")}" if i.time > Time.mktime(2007)
        msg = "Предмет '#{i.name}', Тип предмета: #{i.tip} [#{time}] (#{n+1}/#{nums})\n"
        for t in 0..12
          t1 = keys1[t]
          t2 = keys2[t]
        msg += "#{t1}: #{i[t2]}\n" unless "#{i[t2]}".empty?
        end
        msg.chomp!
        @irc.privmsg cmd.reply, msg
      else
        @irc.privmsg cmd.reply, "Item not found"
      end
    end
  end

  def privmsg_filter(cmd)
    cmd.args(1, 0) == "!it"
  end

  class SowItem < ActiveRecord::Base
  end

  class SowItem::Install < ActiveRecord::Migration
    def self.up
      create_table :sow_items do |t|
        t.column :name, :string, :limit => 60
        t.column :tip, :text
        t.column :lvl, :text
        t.column :flags_pr, :text
        t.column :flags_or, :text
        t.column :flags_zap, :text
        t.column :affects, :text
        t.column :weigth, :text
        t.column :slot, :text
        t.column :color, :text
        t.column :wp_skill, :text
        t.column :dmg, :text
        t.column :spell, :text
        t.column :skill, :text
        t.column :modif, :text
        t.column :time, :datetime
      end
      add_index :sow_items, :name, :unique => true
    end
  end

  def self.install
    unless SowItem.table_exists?
      SowItem::Install.migrate :up
    end
  end

end

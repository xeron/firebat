# coding: utf-8

class SowAdditemCommand < FireBatCommand
  # require_roles :oper

  def on_privmsg(cmd)
    if @prop == "Предмет "
      if @val =~ /'(.*)', Тип предмета: (.*)/
        @val, type = $1, $2
      end
      @i.destroy if @i = SowItem.find_by_name(@val)
      @sttime = Time.now
      @nickold = cmd.nick
      @i = SowItem.create(:name => @val, :tip => type, :modif => "", :time => @sttime)
      reply cmd.nick, "Start logging for #{@i.name}"
    elsif @nickold == cmd.nick
      if Time.now - @sttime <= 30
        keys = {
          "Требует для использования: " => "lvl",
          "Флаги предмета: " => "flags_pr",
          "Флаги оружия  : " => "flags_or",
          "Флаги запрета : " => "flags_zap",
          "Аффекты       : " => "affects",
          "Вес: " => "weigth",
          "Вы можете одеть это на " => "slot",
          "Цвет: " => "color",
          "Оружейное умение: " => "wp_skill",
          "Повреждения: " => "dmg",
          "Заклинание: " => "spell",
          "Умение: " => "skill"
        }
        case @prop
        when "              : "
          @i.flags_zap += "\n              : #{@val}"
          @prop = "Флаги запрета : "
        when " "
          @i.modif += "\n #{@val}"
          @prop = "Модификаторы :"
        else
          field = keys[@prop]
          @i[field] = @val
        end
        @i.save
        reply cmd.nick, "Logged #{@prop} for #{@i.name}"
      else
        reply cmd.nick, "30 секунд прошло - облом"
        @nickold = ""
      end
    end
  end

  def privmsg_filter(cmd)
    if !(cmd.args_tail(1, 0) =~ /^         Вн.*/) && (cmd.args_tail(1, 0) =~ /^(Предмет |Требует для использования: |Флаги предмета: |Флаги оружия  : |Флаги запрета : |              : |Аффекты       : |Вес: |Вы можете одеть это на |Цвет: |Оружейное умение: |Повреждения: |Заклинание: |Умение: | )(.*)$/)
      @prop, @val = $1, $2
    end
  end

  class SowItem < ActiveRecord::Base
  end

end

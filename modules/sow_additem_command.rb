# coding: utf-8

class SowAdditemCommand < FireBatCommand
  # require_roles :oper

  def on_privmsg( cmd )
    if @prop == "Предмет "
      if @val =~ /'(.*)', Тип предмета: (.*)/
        type = $2
        @val = $1
      end
      @i.destroy if @i = SowItem.find_by_name(@val)
      @sttime = Time.now
      @nickold = cmd.nick
      @i = SowItem.create(:name => @val, :tip => type, :modif => "",:time => @sttime)
      reply cmd.nick, "Start logging for #{@i.name}"
    elsif ((Time.now - @sttime < 20) && (@nickold == cmd.nick))
      keys = {"Требует для использования: " => "lvl","Флаги предмета: " => "flags_pr","Флаги оружия  : " => "flags_or","Флаги запрета : " => "flags_zap","Аффекты       : " => "affects","Вес: " => "weigth","Вы можете одеть это на " => "slot","Цвет: " => "color","Оружейное умение: " => "wp_skill","Повреждения: " => "dmg","Заклинание: " => "spell","Умение: " => "skill"}
      field = keys[@prop]
      @i[field] = @val
      if @prop == "              : "
        @i.flags_zap += "\n              : #{@val}"
      elsif @prop == " "
        @i.modif += "\n #{@val}"
        @prop = ""
      end
      @i.save
      reply cmd.nick, "Logged #{@prop} for #{@i.name}"
    elsif ((cmd.nick == @nickold) && (Time.now - @sttime > 20))
      reply cmd.nick, "20 секунд прошло - облом"
      @nickold = ""
    end
  end

  def privmsg_filter( cmd )
    if cmd.args_tail(1,0) =~ /^(Предмет |Требует для использования: |Флаги предмета: |Флаги оружия  : |Флаги запрета : |              : |Аффекты       : |Вес: |Вы можете одеть это на |Цвет: |Оружейное умение: |Повреждения: |Заклинание: |Умение: | )(.*)$/
      @prop = $1
      @val = $2
    end
  end

  class SowItem < ActiveRecord::Base
  end

end

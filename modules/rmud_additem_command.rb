# coding: utf-8

class RmudAdditemCommand < FireBatCommand
  require_roles :oper

  def on_privmsg(cmd)
    if @prop == "Название:"
      @i.destroy if @i = RmudItem.find_by_name(@val)
      @sttime = Time.now
      @nickold = cmd.nick
      @i = RmudItem.create(:name => @val, :time => @sttime)
      reply cmd.nick, "Start logging for #{@i.name}"
    elsif ((Time.now - @sttime < 10) && (@nickold == cmd.nick))
      keys = {
        "Свойства:" => "prop",
        "Тип:" => "tip",
        "Ограничения:" => "lim",
        "Влияния:" => "vli",
        "Эффекты:" => "eff",
        "Содержит заклинание:" => "spell",
        "Заряды:" => "spells",
        "Сила удара:" => "dmg",
        "Качество брони:" => "armor",
        "Содержит:" => "spell",
        "С:" => "S"
      }
      field = keys[@prop]
      @i[field] = @val
      @i.save
      reply cmd.nick, "Logged #{@prop} for #{@i.name}"
    else
      reply cmd.nick, "10 секунд прошло - облом"
    end
  end

  def privmsg_filter(cmd)
    if cmd.args_tail(1, 0) =~ /^(Название:|Тип:|Свойства:|Ограничения:|Влияния:|Эффекты:|Содержит заклинание:|Заряды:|Сила удара:|Тип:|Качество брони:|Содержит:|С:) (.*)$/
      @prop, @val = $1, $2
    end
  end

  class RmudItem < ActiveRecord::Base
  end

end

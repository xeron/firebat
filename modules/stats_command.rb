# coding: utf-8

class StatsCommand < FireBatCommand
  def on_privmsg(cmd)
   ks = cmd.args_tail(1, 1).split(/[ Ловкость:   Телосложение:   Разум:   Мудрость: ]+/)
   k = ks[0].to_i + ks[1].to_i + ks[2].to_i + ks[3].to_i + ks[4].to_i + ks[5].to_i
   @irc.privmsg cmd.reply, "Сумма=#{k}" if ks[1] != nil
  end

  def privmsg_filter(cmd)
    cmd.args(1, 0) == "Сила:"
  end
end

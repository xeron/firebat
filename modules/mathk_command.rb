# coding: utf-8

class MathkCommand < FireBatCommand
  def on_privmsg(cmd)
    ks = cmd.args(1, 1).split(/[kк]+/)
    ks[0] = ks[0].to_i
    ks[1] = ks[1].to_i
    max = ks[0]*ks[1]
    avg = (ks[0] + max) / 2
    @irc.privmsg cmd.reply, "Min=#{ks[0]}, Max=#{max}, Avg=#{avg}"
  end

  def privmsg_filter(cmd)
    cmd.args(1, 0) == "!k"
  end
end

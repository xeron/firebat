# coding: utf-8

class PrivetCommand < FireBatCommand
  def on_privmsg(cmd)
    @irc.privmsg cmd.reply, "ку, #{cmd.nick}"
  end

  def privmsg_filter(cmd)
    cmd.args_tail(1, 0) =~ /^(re|ку|привет)$/
  end
end

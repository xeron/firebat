class PingCommand < FireBatCommand

  def on_privmsg(cmd)
    @irc.privmsg cmd.reply, "!pong"
  end
  
  def privmsg_filter(cmd)
    cmd.args(1,0) == "!ping"
  end

end

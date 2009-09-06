class RehashCommand < FireBatCommand
  require_roles :admin
  
  def on_privmsg(cmd)
    @irc.rehash
    reply cmd.nick, "Rehashed!"
  end
  
  def privmsg_filter(cmd)
    cmd.args(1,0) == "!rehash"
  end
end

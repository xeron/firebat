class JoinCommand < FireBatCommand
  require_roles :oper
  
  def on_privmsg( cmd )
    @irc.join cmd.args(1,1)
  end
  
  def privmsg_filter( cmd )
    cmd.args(1,0) == "!join"
  end
end

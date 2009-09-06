class SayCommand < FireBatCommand
  require_roles :oper
  
  def on_privmsg( cmd )
    @irc.privmsg cmd.args(1,1), cmd.args_tail(1,2)
  end
  
  def privmsg_filter( cmd )
    cmd.args(1,0) == "!say"
  end
end

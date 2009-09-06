class PartCommand < FireBatCommand

  require_roles :oper

  def on_privmsg( cmd )
    if !cmd.args(1,1)
      @irc.part cmd.reply
    else
      @irc.part cmd.args(1,1), cmd.args_tail(1,2)
    end
  end
  
  def privmsg_filter( cmd )
    cmd.args(1,0) == "!part"
  end

end

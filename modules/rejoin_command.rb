class RejoinCommand < FireBatCommand
  require_roles :oper

  def on_privmsg(cmd)
    if !cmd.args(1, 1)
      chan = cmd.reply
      @irc.part chan
    else
      chan = cmd.args(1, 1)
      @irc.part chan, cmd.args_tail(1, 2)
    end
    @irc.join chan
  end

  def privmsg_filter(cmd)
    cmd.args(1, 0) == "!rejoin"
  end
end

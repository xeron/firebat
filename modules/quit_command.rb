class QuitCommand < FireBatCommand
  require_roles :admin

  def on_privmsg(cmd)
    @irc.quit cmd.args_tail(1, 1)
  end

  def privmsg_filter(cmd)
    cmd.args(1, 0) == "!quit"
  end
end

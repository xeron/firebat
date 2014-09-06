class Develop < FireBatCommand
  require_roles :admin

  def on_privmsg(cmd)
    if cmd.args(1, 1) =~ /on|1/
      @irc.develop = true
      msg = "on"
    else
      @irc.develop = false
      msg = "off"
    end
    reply cmd.nick, "developer mode is #{msg}"
  end

  def privmsg_filter(cmd)
    cmd.args(1, 0) == "!develop"
  end
end

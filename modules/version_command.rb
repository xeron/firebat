class VersionCommand < FireBatCommand
  def on_privmsg(cmd)
    @irc.privmsg cmd.reply, "FireBat5 IRC Bot v1.0. Programming by ru && Xeron"
  end

  def privmsg_filter(cmd)
    cmd.args(1, 0) == "!version"
  end
end

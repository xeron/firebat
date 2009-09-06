class VersionCommand < FireBatCommand

  def on_privmsg(cmd)
    @irc.privmsg cmd.reply, "FireBat IRC Bot v0.1.30. Programming by ru: core, modules && Xeron: modules"
  end
  
  def privmsg_filter(cmd)
    cmd.args(1,0) == "!version"
  end

end

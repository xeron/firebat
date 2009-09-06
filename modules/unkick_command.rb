class UnkickCommand < FireBatCommand

  def on_kick( cmd )
    @irc.join cmd.reply
  end
  
  def kick_filter( cmd )
    cmd.args(1,0) == "RMUD"
  end
end

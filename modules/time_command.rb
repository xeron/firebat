class TimeCommand < FireBatCommand

  def on_privmsg( cmd )
    @irc.privmsg cmd.reply, "Сейчас #{Time.now.strftime("%H:%M:%S, %d.%m.%Y")}"
  end
  
  def privmsg_filter( cmd )
    cmd.args(1,0) == "!time"
  end

end

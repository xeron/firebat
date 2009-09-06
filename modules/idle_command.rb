class IdleCommand < FireBatCommand

  def on_privmsg(cmd)
    @irc.service(WhoisService).work(cmd.args(1,1)) do |whois|
      @irc.privmsg cmd.reply,
      if whois.status
        "#{whois.nick} молчит #{Time.at(whois.idle.to_i).getutc.format_irc}."
      else
        "#{whois.nick} не найден в сети."
      end
    end
  end
  
  def privmsg_filter( cmd )
    cmd.args(1,0) == "!idle"
  end
end
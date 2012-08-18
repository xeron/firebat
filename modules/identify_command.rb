class IdentifyCommand < FireBatCommand
  def on_notice(cmd)
    @irc.nickserv "identify #{@irc.config[:nspassword]}"
  end

  def notice_filter(cmd)
    cmd.args_tail(1, 0) =~ /NickServ IDENTIFY/
  end
end

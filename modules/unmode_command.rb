class UnmodeCommand < FireBatCommand

  def on_mode( cmd )
    if cmd.args(2) =~ /^(\S+)(91\.146\.43\.180|mandriva\.izhnet\.org)$/
      @irc.mode cmd.reply, "-b", cmd.args(2)
    end
    @irc.chanserv "unban #{cmd.reply}"
    @irc.chanserv "op #{cmd.reply} #{@irc.config[:nick]}"
  end
  
  def mode_filter( cmd )
    cmd.args(1,0) =~ /(.*)(\+b|\-o)(.*)/
  end

end

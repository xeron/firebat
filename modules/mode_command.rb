class ModeCommand < FireBatCommand
  require_roles :oper

  def on_privmsg( cmd )
    keys = {"op" => "+o","hop" => "+h","voi" => "+v","deop" => "-o","dehop" => "-h","devoi" => "-v","ban" => "+b","unban" => "-b"}
    chan = cmd.args(0)
    if cmd.args_tail(1,1) =~ /^(#\S+) (\S+)(.*)$/
      chan = $1
      target = $2
    elsif cmd.args(1,1)
      target = cmd.args(1,1)
    else
      target = cmd.nick
    end
    if ((@com == "ban") || (@com == "unban"))
      @irc.service(WhoisService).work(target) do |whois|
        if whois.status
          target2 = "*@#{whois.host}"
          puts "ERROR - NO KEY FOR #{@com}" if keys[@com] != "-b" or keys[@com] != "+b"
          @irc.mode chan, keys[@com], target2
          @irc.kick chan, target, "requested by RMUD operator" if @com == "ban"
        end
      end
    elsif @com == "kick"
      @irc.kick chan, target, "requested by RMUD operator"
    else
      @irc.mode chan, keys[@com], target
    end
  end

  def privmsg_filter( cmd )
    cmd.args(1,0) =~ /^!(op|hop|voi|deop|dehop|devoi|ban|unban|kick)/
    @com = $1
  end
end

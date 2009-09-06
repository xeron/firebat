class Develop < FireBatCommand
  require_roles :admin
  
  def on_privmsg( cmd )
    reply cmd.nick, "developer mode " + if cmd.args(1,1) =~ /on|1/
                                @irc.develop = 1
                                "on"
                              else
                                @irc.develop = nil
                                "off"
                              end
  end
  
  def privmsg_filter( cmd )
    cmd.args(1,0) == "!develop"
  end
end

class EventDump < FireBatCommand
  require_roles :admin

  def on_privmsg(cmd)
    s = ""
    @irc.events.events.each_pair do |event_name, event|
      s += "#{event_name}("
      for ev in event
        s += ev.class.to_s + " "
      end
      s.chop!
      s += ") "
    end
    reply cmd.nick, s.chop
  end

  def privmsg_filter(cmd)
    cmd.args(1,0) == "!events"
  end
end

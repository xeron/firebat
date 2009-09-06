class TopicCommand < FireBatCommand
  require_roles :oper
  
  def on_privmsg( cmd )
    chan = cmd.args(0)
    if cmd.args_tail(1,1) =~ /^(#\S+) (.*)$/
      chan = $1
      text = $2
    elsif cmd.args_tail(1,1).any?
      text = cmd.args_tail(1,1)
    end
    @irc.topic chan, text
  end
  
  def privmsg_filter( cmd )
    cmd.args(1,0) == "!topic"
  end
end

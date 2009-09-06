class PingPongCommand < FireBatCommand
  def on_ping(cmd)
    @irc.pong cmd.args(0)
  end
end

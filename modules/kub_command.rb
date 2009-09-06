class KubCommand < FireBatCommand

  def on_privmsg( cmd )
    k1 = rand(6)+1
    k2 = rand(6)+1
    k3 = k2 + k1
    @irc.privmsg cmd.reply, "#{k1}+#{k2}=#{k3}"
  end
  
  def privmsg_filter( cmd )
    cmd.args(1,0) == "кости"
  end

end

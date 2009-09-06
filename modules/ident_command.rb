class IdentCommand < FireBatCommand
#  reply_style :notice
  
  def on_privmsg( cmd )
    username = cmd.nick
    password = cmd.args(1,1)
    msg =
    if u = User.find_by_name_and_password(username, password)
      u.authorised = true
      u.save
      "You are authorised"
    else
      "Invalid password or you not registered?"
    end
    reply cmd.nick, msg
  end
  
  def privmsg_filter( cmd )
    cmd.args(1,0) =~ /^identify/
  end
end

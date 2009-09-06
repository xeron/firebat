class RegisterCommand < FireBatCommand
  require_roles :admin

  def on_privmsg( cmd )
#    username = cmd.nick
    username = cmd.args(1,1)
    password = cmd.args(1,2)
    msg = 
    if User.find_by_name(username)
      "nick is already registered"
    else
      if User.create(:name => username, :password => password, :registered_at => Time.now)
        "#{username} have been successfully registered!"
      end
    end
    reply cmd.nick, msg
  end
  
  def privmsg_filter( cmd )
    cmd.args(1,0) == "!register"
  end
end

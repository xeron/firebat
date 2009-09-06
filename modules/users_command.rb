class UsersCommand < FireBatCommand
  require_roles :admin
  
  def on_privmsg( cmd )
    msg=
    case cmd.args(1,1)
      when "list" then list
      when "list-all" then list_all
      when "rm" then remove( cmd.args(1,2) )
      when "info" then info( cmd.args(1,2) )
      when "add" then add( cmd.args(1,2) )
      when "promote" then promote( cmd.args(1,2), cmd.args(1,3) )
      when "demote" then demote( cmd.args(1,2), cmd.args(1,3) )
      when "help" then help
      else "use !users help for full help" 
    end
    reply cmd.nick, msg
  end
  
  def list
    msg = "["
    User.find(:all,["password <> ''"]).each do |u|
      msg += u.name + ", "
    end
    msg.chop!
    msg.chop!
    msg += "]" 
  end

  def list_all
    msg = "["
    User.find(:all).each do |u|
      msg += u.name + ", "
    end
    msg.chop!
    msg.chop!
    msg += "]" 
  end
  
  def remove(name)
    if u = User.find_by_name(name)
      u.destroy
      "User deleted"
    else
      "User not found"
    end
  end
  
  def info(name)
    if u = User.find_by_name(name)
      roles_str = "[" + u.roles.map{|r| r.name}.join(", ") + "]"
      "User #{u.name} ##{u.id}, #{u.authorised ? 'authorised, ' : ''}password: #{u.password}, registered-at: #{u.registered_at}. Roles: #{roles_str}"
    else
      "User not found"
    end
  end
  
  def add(name)
    if u = User.find_by_name(name)
      "User already exists"
    else
      u = User.create(:name => name)
      "User added #{u.id}"
    end
  end
  
  def promote(name,role)
    if u = User.find_by_name(name)
      if r = Role.find_by_name(role)
        if u.roles.find_by_name(role)
          "Role is already exists!"
        else
          u.roles << r
          "Role added"          
        end
      else
        "Role not found"
      end      
    else
      "User not found"
    end
  end
  
  def demote(name,role)
    if u = User.find_by_name(name)
      if r = Role.find_by_name(role)
        if u.roles.find_by_name(role)
          u.roles.delete(r)
          "Role deleted"
        else
          "Role is not exists for this user"          
        end
      else
        "Role not found"
      end      
    else
      "User not found"
    end
  end
  
  def help
"User controller module for RMUD IRC Bot. Written by ru. Syntaxis: !users action <params>. Actions:
    !users list => Displays all registered users list
    !users rm name => Deletes user with name = name
    !users info name => Show full info about user
    !users promote name role => Add role to user
    !users demote name role => Delete role from user"
  end
  
  def privmsg_filter( cmd )
    cmd.args(1,0) == "!users"
  end
  
end

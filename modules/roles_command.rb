class RolesCommand < FireBatCommand
  require_roles :admin
  
  def on_privmsg( cmd )
    msg=
    case cmd.args(1,1)
      when "list" then list
      when "rm" then remove( cmd.args(1,2) )
      when "info" then info( cmd.args(1,2) )
      when "add" then add( cmd.args(1,2) )
      when "help" then help
      else "use !roles help for full help" 
    end
    reply cmd.nick, msg 
  end
  
  def list
    msg = "["
    Role.find(:all).each do |u|
      msg += u.name + ", "
    end
    msg.chop!
    msg.chop!
    msg += "]" 
  end
  
  def remove(name)
    if u = Role.find_by_name(name)
      u.destroy
      "Role deleted"
    else
      "Role not found"
    end
  end
  
  def info(name)
    if u = Role.find_by_name(name)
      "Role #{u.name} ##{u.id}"
    else
      "Role not found"
    end
  end
  
  def add(name)
    if u = Role.find_by_name(name)
      "Role already exists"
    else
      Role.create(:name => name)
      "Role added"
    end
  end
  
  def help
"Roles controller module for FireBat5. Written by ru. Roles uses for split access for different commands to different users. Syntaxis: !roles action <params>. Action:
    !roles list => Displays all roles
    !roles rm name => Deletes role with name = name
    !roles info name => Show full info about role
    !roles add name => Add role"
  end
  
  def privmsg_filter( cmd )
    cmd.args(1,0) == "!roles"
  end
end

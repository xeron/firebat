class RolesCommand < FireBatCommand
  require_roles :admin

  def on_privmsg(cmd)
    msg = case cmd.args(1, 1)
    when "list" then list
    when "rm" then remove(cmd.args(1, 2))
    when "info" then info(cmd.args(1, 2))
    when "add" then add(cmd.args(1, 2))
    when "help" then help
    else "use !roles help for full help"
    end
    reply cmd.nick, msg
  end

  def list
    "[" + Role.all.collect(&:name).join(", ") + "]"
  end

  def remove(name)
    if r = Role.find_by_name(name)
      r.destroy
      "Role #{r.name} deleted"
    else
      "Role #{name} not found"
    end
  end

  def info(name)
    if r = Role.find_by_name(name)
      "Role #{r.name}, ##{r.id}, users: [" + r.users.collect(&:name).join(", ") + "]"
    else
      "Role #{name} not found"
    end
  end

  def add(name)
    if r = Role.find_by_name(name)
      "Role #{name} already exists"
    else
      r = Role.create(:name => name)
      "Role #{r.name} added, ##{r.id}"
    end
  end

  def help
"Roles controller module for FireBat5. Syntax: !roles action <params>. Actions:
    !roles list => Display all roles
    !roles rm name => Delete role with given name
    !roles info name => Show full info about role
    !roles add name => Add role"
  end

  def privmsg_filter(cmd)
    cmd.args(1, 0) == "!roles"
  end
end

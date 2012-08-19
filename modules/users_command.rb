class UsersCommand < FireBatCommand
  require_roles :admin

  def on_privmsg(cmd)
    msg = case cmd.args(1, 1)
    when "list" then list
    when "list-all" then list_all
    when "rm" then remove(cmd.args(1, 2))
    when "info" then info(cmd.args(1, 2))
    when "add" then add(cmd.args(1, 2))
    when "promote" then promote(cmd.args(1, 2), cmd.args(1, 3))
    when "demote" then demote(cmd.args(1, 2), cmd.args(1, 3))
    when "help" then help
    else "use !users help for full help"
    end
    reply cmd.nick, msg
  end

  def list
    "[" + User.find(:all, ["password <> ''"]).collect(&:name).join(", ") + "]"
  end

  def list_all
    "[" + User.all.collect(&:name).join(", ") + "]"
  end

  def remove(name)
    if u = User.find_by_name(name)
      u.destroy
      "User #{u.name} deleted"
    else
      "User #{name} not found"
    end
  end

  def info(name)
    if u = User.find_by_name(name)
      roles_str = "[" + u.roles.collect(&:name).join(", ") + "]"
      "User #{u.name}, ##{u.id}, #{u.authorised ? 'authorised, ' : ''}password: #{u.password}, registered-at: #{u.registered_at}, roles: #{roles_str}"
    else
      "User #{name} not found"
    end
  end

  def add(name)
    if u = User.find_by_name(name)
      "User #{u.name} already exists"
    else
      u = User.create(:name => name)
      "User added, ##{u.id}"
    end
  end

  def promote(name, role)
    if u = User.find_by_name(name)
      if r = Role.find_by_name(role)
        if u.roles.find_by_name(role)
          "User #{u.name} already has role #{r.name}"
        else
          u.roles << r
          "Role #{r.name} added to #{u.name}"
        end
      else
        "Role #{role} not found"
      end
    else
      "User #{name} not found"
    end
  end

  def demote(name, role)
    if u = User.find_by_name(name)
      if r = Role.find_by_name(role)
        if u.roles.find_by_name(role)
          u.roles.delete(r)
          "Role #{r.name} deleted from #{u.name}"
        else
          "User #{u.name} hasn't role #{r.name}"
        end
      else
        "Role #{role} not found"
      end
    else
      "User #{name} not found"
    end
  end

  def help
"User controller module for FireBat5. Syntax: !users action <params>. Actions:
    !users list => Display all registered users list
    !users rm name => Delete user with given name
    !users info name => Show full info about user
    !users promote name role => Add role to user
    !users demote name role => Delete role from user"
  end

  def privmsg_filter(cmd)
    cmd.args(1, 0) == "!users"
  end

end

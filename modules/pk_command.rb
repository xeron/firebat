class PkCommand < FireBatCommand
  require_roles :oper

  def on_privmsg(cmd)
    if cmd.args(1, 1)
      msg =
        case cmd.args(1, 1)
        when '+' then add(cmd.args(1, 2), cmd.args_tail(1, 3), cmd.nick)
        when '-' then rm(cmd.args_tail(1, 2))
        when 'help' then help(cmd)
        else info(cmd.args_tail(1, 1))
        end
    else
      msg = list
    end

    @irc.privmsg cmd.reply, msg
  end

  def list
    'Найдено: [' + Pk.all.order(:name).collect(&:name).join(', ') + ']'
  end

  def info(name)
    if (pk = Pk.where('name like ?', "%#{name}%").first)
      "Найдено: #{pk.name}. Добавил: #{pk.by}\nПричина: #{pk.reason}"
    else
      "Не найдено: #{name}"
    end
  end

  def add(name, reason, nick)
    if (pk = Pk.find_by_name(name))
      pk.reason = reason
      pk.save
      "Причина для #{name} обновлена"
    else
      Pk.create(name: name, reason: reason, by: nick)
      "#{name} добавлен в список жертв!"
    end
  end

  def rm(name)
    if (p = Pk.find_by_name(name))
      p.destroy
      "#{name} удален из списка"
    else
      "Не найдено: #{name}"
    end
  end

  def help(cmd)
    msg = <<~EOS
      Модуль контроля пк-листа для RMUD IRC Bot. Автор: Xeron. Синтаксис: !пк action <params>.
      Actions:
      !пк => Показывает пк-лист
      !пк <имя> => Показывает персонажа и причину
      !пк + <имя> <причина> => Добавляет в список, либо обновляет причину
      !пк - <имя> => Удаляет из списка
    EOS
    reply cmd.nick, msg
    false
  end

  def privmsg_filter(cmd)
    cmd.args(1, 0) == '!пк'
  end

  class Pk < ActiveRecord::Base
  end

  class Pk::Install < ActiveRecord::Migration[7.1]
    def self.up
      create_table :pks do |t|
        t.column :by, :string, limit: 30
        t.column :name, :string, limit: 100
        t.column :reason, :text
      end
      add_index :pks, :name, unique: true
    end
  end

  def self.install
    Pk::Install.migrate :up unless Pk.table_exists?
  end
end

# coding: utf-8

class QuoteCommand < FireBatCommand

  def on_privmsg(cmd)
    count = Quote.where(channel: cmd.args(0)).count
    n = @arg.to_i - 1

    case @com
    when "aq" || "дц"
      q = Quote.create(:text => @arg, :by => cmd.nick, :time => Time.now, :channel => cmd.args(0))
      msg = "Цитата добавлена с номером: #{count + 1}"
    when "dq"
      if cmd.user.allowed?("oper")
        if (n >= 0) && (q = Quote.where(:channel => cmd.args(0)).order(:id).offset(n).first)
          q.destroy
          msg = "Цитата номер #{@arg} удалена"
        else
          msg = "Нет цитаты с таким номером"
        end
      else
        msg = "У вас нет прав на использование этой команды"
      end
    else
      if (n >= 0) && (q = Quote.where(:channel => cmd.args(0)).order(:id).offset(n).first)
        msg = "(#{n + 1}/#{count}) #{q.text} || Добавил: #{q.by} [#{q.time.strftime("%d.%m.%Y (%H:%M)")}]"
      else
        msg = "Нет цитаты с таким номером"
      end
    end
    @irc.privmsg cmd.reply, msg
  end

  def privmsg_filter(cmd)
    if (cmd.args(0) =~ /^#/) && (cmd.args_tail(1, 0) =~ /^!(aq|dq|q|ц|дц) (.*)$/)
      @com, @arg = $1, $2
    end
  end

  class Quote < ActiveRecord::Base
  end

  class Quote::Install < ActiveRecord::Migration
    def self.up
      create_table :quotes do |t|
        t.column :by, :string, :limit => 30
        t.column :text, :text
        t.column :time, :datetime
        t.column :channel, :string
      end
    end
  end

  def self.install
    unless Quote.table_exists?
      Quote::Install.migrate :up
    end
  end

end

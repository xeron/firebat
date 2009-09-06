class QuoteCommand < FireBatCommand
  
  def on_privmsg( cmd )
    if ((@com == "aq") || (@com == "дц"))
      nums = Quote.count(:conditions => ["channel = ?", cmd.args(0)])
      q = Quote.create(:text => @arg, :by => cmd.nick, :time => Time.now, :channel => cmd.args(0))
      @irc.privmsg cmd.reply, "Цитата добавлена с номером: #{nums+1}"
    elsif @com == "dq"
    if cmd.user.allowed?("oper") 
      n = @arg.to_i - 1
      if ((n >= 0) && (q = Quote.find(:first, :conditions => ["channel = ?", cmd.args(0)], :order => "id", :offset => n)))
        @irc.privmsg cmd.reply, "Цитата номер #{@arg} удалена"
        q.destroy
      else
        @irc.privmsg cmd.reply, "Нет цитаты с таким номером"
      end
    else
      @irc.privmsg cmd.reply, "У вас нет прав на использование этой команды"
    end
    else
      nums = Quote.count(:conditions => ["channel = ?", cmd.args(0)])
      n = @arg.to_i - 1
      if ((n >= 0) && (q = Quote.find(:first, :conditions => ["channel = ?", cmd.args(0)], :order => "id", :offset => n)))
        @irc.privmsg cmd.reply, "(#{n+1}/#{nums}) #{q.text} || Добавил: #{q.by} [#{q.time.strftime("%d.%m.%Y (%H:%M)")}]"
      else
        @irc.privmsg cmd.reply, "Нет цитаты с таким номером"
      end
    end
  end
  
  def privmsg_filter( cmd )
    cmd.args(0) =~ /^#/ and cmd.args_tail(1,0) =~ /^!(aq|dq|q|ц|дц) (.*)$/
    @com = $1
    @arg = $2
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
    unless Seen.table_exists?
      Seen::Install.migrate :up
    end
  end

end

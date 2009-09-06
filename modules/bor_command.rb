class BorCommand < FireBatCommand

  def on_privmsg(cmd)
    n = cmd.args(1,1)
    if q = Borquote.find_by_num(n)
      msg = q.text
    else
      kol = 0
      hash = BashOrgRu.get(n)
      nums_exists = Borquote.find(:all, :select => "num", :conditions => ["num in (?)",hash.keys]).map {|q| q.num}
      hash.reject!{|k,v| nums_exists.include? k}
      hash.each {|key, value|
          q = Borquote.create(:num => key, :text => value.gsub("\n","").gsub("\r","").gsub("<br>","\n").gsub("&lt;","<").gsub("&gt;",">").gsub("\t","").gsub("&quot;","\"").gsub("<br />","\n").gsub("&amp;","&"))
          kol += 1
      }
      if kol == 1
        msg = q.text
      else
        msg = "А нет такой цитаты"
      end
    end
    @irc.privmsg cmd.reply, msg
  end

  def privmsg_filter( cmd )
    cmd.args(1) =~ /^!bor (\d+)$/
  end

  class BashOrgRu
    def self.get(quote_id)
      data = open("http://bash.org.ru/quote/#{quote_id}").read
      data = Iconv.new('utf8', 'cp1251').iconv(data)
      hash = {}
      data.scan(/>(\d+)<\/a>(.*?)<div>(.*?)<\/div>/m).each {|key, trash, value| hash[key.to_i] = value}
      return hash
    end
  end

  class Borquote < ActiveRecord::Base
  end

  class Borquote::Install < ActiveRecord::Migration
    def self.up
      create_table :borquotes do |t|
        t.column :num,  :integer
        t.column :text, :text
      end
    end
  end

  def self.install    
    unless Seen.table_exists?
      Seen::Install.migrate :up
    end
    add_index :borquotes, :num, :name => "num", :unique => true
  end

end
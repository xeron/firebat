# coding: utf-8

class BorCommand < FireBatCommand

  def on_privmsg(cmd)
    n = cmd.args(1, 1)
    if q = Borquote.find_by_num(n)
      msg = q.text
    else
      count = 0
      hash = BashOrgRu.get(n)
      nums_exist = Borquote.where(num: hash.keys).pluck(:num)
      hash.reject! {|id, quote| nums_exist.include?(id)}
      hash.each do |id, quote|
        q = Borquote.create(:num => id, :text => quote.gsub("\n","").gsub("\r","").gsub("<br>","\n").gsub("&lt;","<").gsub("&gt;",">").gsub("\t","").gsub("&quot;","\"").gsub("<br />","\n").gsub("&amp;","&"))
        count += 1
      end
      if count == 1
        msg = q.text
      else
        msg = "А нет такой цитаты."
      end
    end
    @irc.privmsg cmd.reply, msg
  end

  def privmsg_filter(cmd)
    cmd.args(1) =~ /^!bor (\d+)$/
  end

  class BashOrgRu
    def self.get(quote_id)
      data = open("http://bash.im/quote/#{quote_id}").read
      data.encode!("utf-8", "cp1251")
      hash = {}
      data.scan(/<a href="\/quote.*?class="id">#(\d+).*?<div class="text">(.*?)<\/div>/m).each {|key, value| hash[key.to_i] = value}
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
      add_index :borquotes, :num, :unique => true
    end
  end

  def self.install
    unless Borquote.table_exists?
      Borquote::Install.migrate :up
    end
  end

end

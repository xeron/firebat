# coding: utf-8

class GoogleCommand < FireBatCommand

  def on_privmsg(cmd)
    q = URI.escape(cmd.args_tail(1, 1))
    msg = Google.get(q, "")
    reply cmd.nick, msg
  end

  def privmsg_filter(cmd)
    cmd.args(1, 0) == "!g"
  end

  class Google
    # http://www.google.ru/search?hl=en&q=ruby&ie=utf-8&oe=utf-8&lr=lang_ru - example
    # q = request
    # lang = language for search
    def self.get(q,lang)
      ie = "utf-8" # input encoding
      oe = "utf-8" # output encoding
      hl = "ru" # web lang
      data = open("http://www.google.ru/search?hl=#{hl}&q=#{q}&ie=#{ie}&oe=#{oe}&lr=#{lang}").read
      puts data
      res = ""
      data.scan(/<h3 class="r"><a.*?>(.*?)<\/a><\/h3>.*?<cite>(.*?)<\/cite>.*?<span class="st">(.*?)<\/span>/m)[0..1].each { |title, url, desc| res += "#{url} | #{title}\n#{desc}\n" }
      # just fucking string >^_^< FIXME
      return res.gsub("<b>","").gsub("</b>","").gsub("<br>","").gsub("&lt;","<").gsub("&gt;",">").gsub("&quot;","\"").gsub("&amp;","&").gsub("&middot;","·").gsub("# ","").gsub("&nbsp;"," ")
    end
  end

end

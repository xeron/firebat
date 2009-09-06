class GoogleCommand < FireBatCommand

  def on_privmsg(cmd)
    q = URI.escape(cmd.args_tail(1,1))
    msg = Google.get(q,"")
    reply cmd.nick, msg
  end

  def privmsg_filter( cmd )
    cmd.args(1,0) == "!g"
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
      res = ""
      data.scan(/<h2 class=r><a href="(.*?)"(.*?)l>(.*?)<\/a><\/h2>(.*?)<td class="j"><font size=-1>(.*?)<span class=a>/m)[0..1].each { |url, trash, title, trash2, desc| res += "\n#{url} | #{title}\n#{desc}" }
      # just fucking string >^_^< FIXME
      return res.gsub("<b>","").gsub("</b>","").gsub("<br>","").gsub("&lt;","<").gsub("&gt;",">").gsub("&quot;","\"").gsub("&amp;","&").gsub("&middot;","·")
    end
  end

end
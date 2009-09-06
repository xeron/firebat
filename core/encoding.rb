module FireBat
  class Encoding
    def initialize(irc_charset)
      @server = irc_charset
      locale = `locale | grep LANG`
      locale.gsub!(/["']/,'');
      locale =~ /\.(.*)$/
      @terminal = $1
      @script = $KCODE

      @f_server = Iconv.new(@script,@server)
      @t_server = Iconv.new(@server,@script)
      @f_std = Iconv.new(@script,@terminal)
      @t_std = Iconv.new(@terminal,@script)
    end

    def t_s(str)
      begin
        @t_server.iconv(str)
      rescue => ex
        puts "iconv failed"
      end
    end

    def f_s(str)
      @f_server.iconv(str)
    end

    def t_t(str)
      @t_std.iconv(str)
    end

    def f_t(str)
      @f_std.iconv(str)
    end

  end
end
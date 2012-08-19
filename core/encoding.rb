module FireBat
  class Encoding

    def initialize(irc_charset)
      @server = server = irc_charset
      locale = `locale | grep LANG`
      locale.gsub!(/["']/, '')
      locale =~ /\.(.*)$/
      terminal = $1
      script = 'utf-8'

      @f_server = @t_server = @f_std = @t_std = nil
      if script != server
        @f_server = Iconv.new(script, server)
        @t_server = Iconv.new(server, script)
      end
      if script != terminal
        @f_std = Iconv.new(script, terminal)
        @t_std = Iconv.new(terminal, script)
      end
    end

    def t_s(str)
      begin
        @t_server ? @t_server.iconv(str) : str.force_encoding(@server)
      rescue => ex
        puts "iconv failed in t_s"
      end
    end

    def f_s(str)
      begin
        @f_server ? @f_server.iconv(str) : str.force_encoding(@server)
      rescue => ex
        puts "iconv failed in f_s"
      end
    end

    def t_t(str)
      @t_std ? @t_std.iconv(str) : str.force_encoding(@server)
    end

    def f_t(str)
      @f_std ? @f_std.iconv(str) : str.force_encoding(@server)
    end

  end
end

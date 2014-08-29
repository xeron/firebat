module FireBat
  class Encoding

    attr_reader :script, :server, :terminal

    def initialize(irc_charset)
      @server = irc_charset
      locale = `locale | grep LANG`
      locale.gsub!(/["']/, '')
      locale =~ /\.(.*)$/
      @terminal = $1
      @script = 'utf-8'

      @f_server = @t_server = @f_std = @t_std = nil
      if script != server
        @t_server = @f_server = true
      end
      if script != terminal
        @t_std = @f_std = true
      end
    end

    def t_s(str)
      begin
        @t_server ? str.encode!(server, script) : str.force_encoding(server)
      rescue => ex
        puts "encode failed in t_s"
      end
    end

    def f_s(str)
      begin
        @f_server ? str.encode!(script, server) : str.force_encoding(@server)
      rescue => ex
        puts "encode failed in f_s"
      end
    end

    def t_t(str)
      @t_std ? str.encode!(terminal, script) : str.force_encoding(@server)
    end

    def f_t(str)
      @f_std ? str.encode!(script, terminal) : str.force_encoding(@server)
    end

  end
end

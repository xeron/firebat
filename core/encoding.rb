module FireBat
  class Encoding

    attr_reader :script, :server, :terminal

    def initialize(irc_charset)
      @server = irc_charset
      ENV["LANG"].match(/\.(.*)$/)
      @terminal = $1.downcase
      @script = 'utf-8'

      @t_server = @f_server = (script == server) ? false : true
      @t_std = @f_std = (script == terminal) ? false : true
    end

    def t_s(str)
      begin
        @t_server ? str.encode!(server, script) : str.force_encoding(server)
      rescue => ex
        puts "Encode failed from bot to server."
      end
    end

    def f_s(str)
      begin
        @f_server ? str.encode!(script, server) : str.force_encoding(server)
      rescue => ex
        puts "Encode failed from server to bot."
      end
    end

    def t_t(str)
      @t_std ? str.encode!(terminal, script) : str.force_encoding(server)
    end

    def f_t(str)
      @f_std ? str.encode!(script, terminal) : str.force_encoding(server)
    end

  end
end

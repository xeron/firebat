# coding: utf-8

module FireBat
  class Command

    attr_reader :params , :nick , :ident , :host , :cmd, :src

    def initialize(text)
      @src = text.chomp
      # parsing raw command to prefix, command name and params
      if text =~ /^(:(\S+) +)?(\S+) (.*?)[\r\n]?$/u
        prefix, @cmd, pars = $2, $3, $4
        @params = []
        # parse prefix for nick ident and host
        if prefix =~ /(\S+)!(\S+)@(\S+)/u
          @nick, @ident, @host = $1, $2, $3
        end
        # parse params to array of its
        if pars=~/^(?:(.*?) )?:(.*)$/u # this test works only if last parameter have : prefix
          p1, p2 = $1, $2
          if p1
            @params = (p1.split " ") + [p2]
          else
            @params = [p2]
          end
        else
          # pars cannot be parsed in that way. maybe it is last parameter?
          @params = pars.split " "
        end
      end
    end

    def code
      if @cmd
        if IRC.metadata
          ext = IRC.metadata[:command_codes][@cmd]
        end
        ext || @cmd.downcase
      else
        "command not found"
      end
    end

    def args(i, j = nil)
      if j
        @params[i].split(" ")[j]
      else
        @params[i]
      end
    end

    def args_tail(i, j)
      @params[i].split(" ", j + 1)[j].to_s
    end

    def reply
      if @params[0] =~ /^#/
        @params[0]
      else
        @nick
      end
    end

    def user
      if @user
        @user
      else
        @user = User.find_by_name(@nick)
      end
    end

  end
end

if $0 == __FILE__
  p Command.new(":PRIVMSG user!user@user  #x-19-x :!дикей - тест").args_tail(1,3) == ""
  p Command.new(":PRIVMSG user!user@user  #x-19-x :!дикей - тест тест").args_tail(1,3) == "тест"
  p Command.new(":Xeron!~atashi|wa@88.80.36.76 PART #vibration").args(0) == "#vibration"
end

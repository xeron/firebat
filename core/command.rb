module FireBat
  class Command
    attr_reader :params, :nick, :ident, :host, :cmd, :src

    def initialize(text)
      @src = text.chomp
      # parsing raw command to prefix, command name and params
      if text =~ /^(:(\S+) +)?(\S+) (.*?)[\r\n]?$/u
        prefix = Regexp.last_match[2]
        @cmd = Regexp.last_match[3]
        pars = Regexp.last_match[4]

        # parse prefix for nick ident and host
        parse_prefix(prefix)

        # parse params to array of its
        parse_params(pars)
      end
    end

    def parse_prefix(prefix)
      if prefix =~ /(\S+)!(\S+)@(\S+)/u
        @nick = Regexp.last_match[1]
        @ident = Regexp.last_match[2]
        @host = Regexp.last_match[3]
      end
    end

    def parse_params(pars)
      # this test works only if last parameter have : prefix
      if pars =~ /^(?:(.*?) )?:(.*)$/u
        p1 = Regexp.last_match[1]
        p2 = Regexp.last_match[2]
        @params = p1 ? (p1.split ' ') + [p2] : [p2]
      else
        # pars cannot be parsed in that way. Maybe it is last parameter?
        @params = pars.split ' '
      end
    end

    def code
      if cmd
        ext = IRC.metadata[:command_codes][cmd] if IRC.metadata
        ext || cmd.downcase
      else
        'command not found'
      end
    end

    def args(i, j = nil)
      if j
        params[i].split(' ')[j]
      else
        params[i]
      end
    end

    def args_tail(i, j)
      params[i].split(' ', j + 1)[j].to_s
    end

    def reply
      if params[0] =~ /^#/
        params[0]
      else
        nick
      end
    end

    def user
      @user ||= User.find_by_name(nick)
    end
  end
end

if $PROGRAM_NAME == __FILE__
  p FireBat::Command.new(
    ':PRIVMSG user!user@user  #x-19-x :!дикей - тест'
  ).args_tail(1, 3) == ''
  p FireBat::Command.new(
    ':PRIVMSG user!user@user  #x-19-x :!дикей - тест тест'
  ).args_tail(1, 3) == 'тест'
  p FireBat::Command.new(
    ':Xeron!~atashi|wa@88.80.36.76 PART #vibration'
  ).args(0) == '#vibration'
end

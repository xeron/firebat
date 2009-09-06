# Служба для выполнения команды whois
# Использование:
#     @irc.service(WhoisService).work(nick_to_whois) do |whois|
#        #работа над whois. Сработает когда придет весь ответ на whois
#    end
#   whois.status - результат. если nil то была ошибка.
class WhoisService < FireBatCommand

  # Внутренний класс - структура whois-а
  class Whois
    attr_accessor :nick,:channels,:idle,:name,:host,:ident,:server,:server_info,:status
  end

  # Дополнение конструктора. Создадим @ans и @block на случай,
  # что если придет ответ, но не было запроса, то не было бы ошибок
  def initialize(irc)
    @ans = Whois.new #!!
    @block = Proc.new {}
    @active = false
    super(irc)
  end
  # рабочий метод службы
  def work(nick,&block)
    @block = block
    @ans = Whois.new
    @ans.nick = nick
    @active = true
    @irc.whois nick, nick
  end
  # фильтры. Все события обрабатываются только при флаге active.
  def rpl_endwhois_filter(cmd)
    @active
  end
  alias rpl_whoisidle_filter        rpl_endwhois_filter
  alias rpl_whoisuser_filter        rpl_endwhois_filter
  alias rpl_whoisserver_filter      rpl_endwhois_filter
  alias rpl_whoisidle_filter        rpl_endwhois_filter
  alias rpl_whoischannels_filter    rpl_endwhois_filter
  alias rpl_whoisoperator_filter    rpl_endwhois_filter
  alias rpl_err_nosuchserver        rpl_endwhois_filter
  # возникает при whois по двум аргументам. при этом не приходит end of whois!
  def on_err_nosuchserver(cmd)
    @active = false
    @block.call @ans
  end
  # обработчики whois (см. RFC1459 6.2 Command responses.)
  def on_rpl_endofwhois(cmd)
    @active = false
    @block.call @ans
  end
  def on_rpl_whoisidle(cmd)
    #"<nick> <integer> :seconds idle"
    @ans.idle = cmd.args(2)
  end
  def on_rpl_whoisuser(cmd)
    #"<nick> <user> <host> * :<real name>"
    @ans.ident, @ans.host, @ans.name = cmd.args(2), cmd.args(3), cmd.args(4)
    @ans.status = true
  end
  def on_rpl_whoisserver(cmd)
    #"<nick> <server> :<server info>"
    @ans.server, @ans.server_info = cmd.args(2), cmd.args(3)
  end
  def on_rpl_whoisoperator(cmd)
  end
  def on_rpl_whoischannels(cmd)
    #"<nick> :{[@|+]<channel><space>}"
    @ans.channels = cmd.args(2)
  end
end
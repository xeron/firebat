# coding: utf-8

class HelpCommand < FireBatCommand
  def on_privmsg( cmd )
    reply cmd.nick,
"Краткая справка по командам:
!item <название шмотки> - лоры вещей
!дикей help (или !декей help) - справка по управлению списком дикеев
!пк help - справка по управлению пк листом
кости - кинуть кости
!q n - посмотреть цитату номер n
!aq <текст> - добавить цитату
!dq n - удалить цитату номер n
!version - версия бота
identify <pass> - авторизация у бота (делайте это в привате)"
  end

  def privmsg_filter( cmd )
    cmd.args(1,0) == "!help"
  end
end

#dummy
class Support
  def initialize(irc)
  end
  def register!
  end
end

class Time
  def diff(time = Time.now)
    Time.at(time - self).getutc
  end
  def format_irc
    if day > 1 #first is 1st Jan = 1 day
      (self - 1.days).strftime("%dдн %Hчас %Mмин %Sсек")
    elsif hour > 0
      strftime("%Hчас %Mмин %Sсек")
    elsif min > 0
      strftime("%Mмин %Sсек")
    else
      strftime("%Sсек")
    end
  end
end

class HelpCommand < FireBatCommand
  
  def on_privmsg( cmd )
    reply cmd.nick,
"������� ������� �� ��������:
!item <�������� ������> - ���� �����
!����� help (��� !����� help) - ������� �� ���������� ������� ������
!�� help - ������� �� ���������� �� ������
����� - ������ �����
!q n - ���������� ������ ����� n
!aq <�����> - �������� ������
!dq n - ������� ������ ����� n
!version - ������ ����
identify <pass> - ����������� � ���� (������� ��� � �������)"
  end
  
  def privmsg_filter( cmd )
    cmd.args(1,0) == "!help"
  end
end

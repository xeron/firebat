require 'rubygems'
require 'active_record'
require 'socket'
require 'pp'
require 'yaml'
require 'open-uri'
require 'uri'
require 'iconv'

require 'core/config'
require 'core/command'
require 'core/database'
require 'core/schema'
require 'core/firebatcommand'
require 'core/user'
require 'core/events'
require 'core/encoding'

$KCODE = 'utf-8'

module FireBat
  class IRC
    attr_reader :options , :sock, :events, :config, :encoder
    attr_accessor :develop
    cattr_accessor :metadata

    # initialize bot using keys nick, ident, username, server, port
    # keys is a symbols in hash
    #
    def initialize(attr)
      attr.symbolize_keys!
      @config = attr
      @nick  = attr[:nick]
      @ident  = attr[:ident]
      @username = attr[:username]
      @server = attr[:server]
      @port = attr[:port]
      @encoder = Encoding.new(attr[:charset])
      @develop = nil
    end

    # connect to server and port, maybe nil
    #
    def connect(server = nil , port = nil)
      @server = server || @server
      @port = port || @port
      @sock = TCPSocket.new(@server , @port)

      puts "creating events"
      @events = Events.new

      @reader = Thread.new(self) do |bot|
        puts "READER STARTED"
        while not bot.sock.eof
          bot.__on_data bot.sock.gets
        end
      end

      User.update_all "authorised = 0"
      send :user , @ident , 0 , 0 , @username
      send :nick , @nick
      @sock.puts
    end

    # send command with any arguments
    # ex: irc.send( "privmsg" , "ru" , "hello" )
    #     irc.send :quit , "blabla"
    #
    def send(command , *args)
      args = args[0] if args[0].class == Array
      if args.length > 0
        args[-1] = ":" + args[-1].to_s
        buf = command.to_s + " " + args.map{|e| e.to_s}.join(" ")
      else
        buf = command.to_s
      end
      @sock.puts(@encoder.t_s(buf))
      puts "=>" + @encoder.t_t(buf)
    end

    # send raw message when it missing
    # ex: irc.nickserv "register", "pass" === irc.send("nickserv","register","pass")
    #
    def method_missing(method, *args, &block)
      send method , args
    end

    # join to many channels, splitted by space
    # channel password stored channel name and sepparated by :
    # ex: #main #private:mypass #channel2
    #
    def multi_join( str )
      str.split(" ").each do |ch|
        if ch =~ /^(.+):(.+)$/
          join $1, $2
        else
          join ch
        end
      end
    end

    # smart privmsg. Can send multiline messages
    def privmsg( to, str )
      return unless str
      str.split(/\n/).each do |s|
        send(:privmsg, to, s)
      end
    end

    def multiline_send(command,*args)
      args[1].split(/\n/).each do |s|
        send(command, args[0], s)
      end
    end

    # data receiver and parser
    # when we receive command we parse it to Command object
    # then, casing type, run event parser
    #
    def __on_data(text)
      if @develop
        puts @develop
        rehash
      end
      text = @encoder.f_s text
      cmd = Command.new text
#      puts "<=" + @encoder.t_t(text)
      @events.parse(cmd)
    end

    def wait!
      @reader.join
    end

    # reloads all commands
    def rehash
      @events.empty!
      @@metadata = File.open("config/metadata.yml"){|f| YAML.load(f) }
      Dir.foreach("modules") do |file|
        if file =~ /^(.+)\.rb$/
          mod = $1
          begin
            load 'modules/' + file
          rescue => ex
            puts "Error load module #{mod}: " + ex.to_s
          end
          eval(mod.camelize).new(self).register!
        end
      end
    end

    #return service object with that name
    def service(classname)
      @events.events.values.flatten.find do |command|
        command.class == classname
      end
    end
  end
end

if __FILE__ == $0
  i = IRC.new :nick => "qu" , :ident => 'z' , :username  => 'qq'
  i.connect 'ameno.idz.ru' , 6667
  i.send :join , '#mark'
end
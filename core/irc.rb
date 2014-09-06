require 'rubygems'
require 'active_record'
require 'logger'
require 'socket'
require 'pp'
require 'yaml'
require 'open-uri'

require 'core/config'
require 'core/command'
require 'core/database'
require 'core/schema'
require 'core/firebatcommand'
require 'core/user'
require 'core/events'
require 'core/encoding'

module FireBat
  class IRC

    attr_reader :sock, :events, :config, :encoder
    attr_accessor :develop
    cattr_accessor :metadata

    # Initialize bot using keys nick, ident, username, server, port
    # keys is a symbols in hash
    #
    def initialize(attr)
      attr.symbolize_keys!
      @config = attr
      @nick = attr[:nick]
      @ident = attr[:ident]
      @username = attr[:username]
      @server = attr[:server]
      @port = attr[:port]
      @encoder = Encoding.new(attr[:charset])
      @develop = false
    end

    # Connect to server and port (can be nil)
    #
    def connect(server = nil, port = nil)
      @server = server || @server
      @port = port || @port
      @sock = TCPSocket.new(@server, @port)

      puts "Creating events..."
      @events = Events.new

      @reader = Thread.new(self) do |bot|
        puts "READER STARTED"
        while not bot.sock.eof
          bot.__on_data bot.sock.gets
        end
      end

      User.update_all(:authorised => false)
      send :user, @ident, 0, 0, @username
      send :nick, @nick
      @sock.puts
    end

    # Send command with any arguments
    # ex: irc.send("privmsg", "ru", "hello")
    #     irc.send :quit, "blabla"
    #
    def send(command, *args)
      args = args[0] if args[0].is_a?(Array)
      buf = []

      if args.length > 0
        body = args[-1].to_s
        args.delete_at(-1)
        command = command.to_s
        command += " " + args.map(&:to_s).join(" ") if args.any?
        command += " :"
        maxlength = 510 - command.bytesize - 40 # 40 for bot mask

        msg = ""
        body.chars.each do |ch|
          msg += ch
          if msg.bytesize >= maxlength
            buf << command + msg
            msg = ""
          end
        end
        buf << command + msg
      else
        buf << command.to_s
      end

      buf.each do |b|
        sock.puts(encoder.t_s(b))
        puts "=>" + encoder.t_t(b)
      end
    end

    # Send raw message when it missing
    # ex: irc.nickserv "register", "pass" === irc.send("nickserv", "register", "pass")
    #
    def method_missing(method, *args, &block)
      send method, args
    end

    # Join to many channels, splitted by space
    # Channel password stored in channel name sepparated by :
    # ex: #main #private:mypass #channel2
    #
    def multi_join(str)
      str.split(" ").each do |ch|
        if ch =~ /^(.+):(.+)$/
          join $1, $2
        else
          join ch
        end
      end
    end

    # Smart privmsg. Can send multiline messages
    #
    def privmsg(to, str)
      return unless str
      str.split(/\n/).each do |s|
        send(:privmsg, to, s)
      end
    end

    def multiline_send(command, *args)
      args[1].split(/\n/).each do |s|
        send(command, args[0], s)
      end
    end

    # Data receiver and parser
    # When we receive command we parse it to Command object
    # then, casing type, run event parser
    #
    def __on_data(text)
      if develop
        puts develop
        rehash
      end
      text = encoder.f_s(text)
      cmd = Command.new text
      # puts "<=" + encoder.t_t(text)
      events.parse(cmd)
    end

    def wait!
      @reader.join
    end

    # Reload all commands
    def rehash
      events.empty!
      @@metadata = YAML.load_file("config/metadata.yml")
      Dir.foreach("modules") do |file|
        if file =~ /^(.+)\.rb$/
          mod = $1
          begin
            load File.join("modules", file)
          rescue => ex
            puts "Error loading module #{mod}: " + ex.to_s
          end
          eval(mod.camelize).new(self).register!
        end
      end
    end

    # Return service object with that name
    def service(classname)
      events.events.values.flatten.find do |command|
        command.class == classname
      end
    end

  end
end

if __FILE__ == $0
  i = IRC.new :nick => "qu", :ident => 'z', :username => 'qq'
  i.connect 'ameno.idz.ru', 6667
  i.send :join, '#mark'
end

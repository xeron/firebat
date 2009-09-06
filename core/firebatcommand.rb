module FireBat
  class FireBatCommand
    # initialize command sending irc connection to it
    # 
    def initialize( irc )
      @irc = irc
    end
  
    # register command
    # 
    # 
    def register!
      self.class.instance_methods.each do |meth|
        if meth =~ /^on_(.+)$/
          puts "add #{meth} to #{self.class.to_s}"
          @irc.events.add( $1, self )
        end
      end
    end
  
    # post filter check access
    #
    def post_filter( cmd )
      begin
        return true unless self.class.roles
        raise "You have no access and no registration" unless cmd.user
        self.class.roles.each do |role|    
          raise "Access denied. You need #{role} role or be authorised" unless cmd.user.allowed?(role.to_s)
        end
        return true
      rescue => ex
        reply cmd.nick, ex.message
        return nil
      end
    end
  
    def reply(*args)
      @irc.multiline_send self.class.reply, args[0], args[1]
    end
  
    class << self
      def roles
        @roles
      end    
      def require_roles(*args)
        @roles = args
      end
      def require_role(*args)
        @roles = args
      end
      def reply_style( s )
        @reply = s
      end
      def reply
        @reply || :notice
      end
    end
  end
end
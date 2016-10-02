module FireBat
  # Events collector
  # It collects handlers for events and can eval them
  class Events
    attr_reader :events

    def initialize
      @events = {}
    end

    # Add command handler as object (class inherits FireBatCommand)
    # Ignore if handler already exists
    # Name arg is command handler name (ex: privmsg, notice)
    def add(name, obj)
      if @events[name] && !@events[name].include?(obj)
        @events[name] << obj
      else
        @events[name] = [obj]
      end
    end

    # Remove object from events
    def delete(obj)
      @events.each do |lists|
        lists.delete(obj)
      end
    end

    def empty!
      @events = {}
    end

    # Scan commands for commands supports cmd.code
    # and invoke on_*cmd.code* method to every command passed filter
    def parse(cmd)
      return unless @events[cmd.code]

      @events[cmd.code].each do |command|
        next unless cmd_filter(cmd, command)

        puts "#{cmd.code} [#{cmd.src}] raises event in #{command.class}"

        next unless cmd_filter(cmd, command, 'post_filter')

        puts 'post-filter passed'

        begin
          command.send(('on_' + cmd.code).to_sym, cmd)
        rescue => ex
          puts "Error! #{ex}"
          print ex.backtrace.join("\n")
        end
      end
    end

    def cmd_filter(cmd, command, filter = nil)
      filter ||= cmd.code + '_filter'
      if command.respond_to?(filter)
        begin
          command.send(filter.to_sym, cmd)
        rescue => ex
          puts "Error in filter! #{ex}"
          print ex.backtrace.join("\n") # print returns nil
        end
      else
        true
      end
    end
  end
end

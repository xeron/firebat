module FireBat
  # Events collector
  # It collects handlers for events, and can eval them
  # 
  class Events
    attr_reader :events
    def initialize
      @events = {}
    end
  
    # add command handler as object (class inherits FireBatCommand)
    # ignore if handler already exists
    # name arg is command handler name (ex: privmsg, notice)
    # 
    def add( name, obj )
      if @events[name]
        unless @events[name].include?( obj )
          @events[name] << obj
        end
      else
        @events[name] = [obj]
      end
    end
  
    # deletes object from events 
    # 
    def delete( obj )
      for lists in @events
        lists.delete( obj )
      end
    end
  
    def empty!
      @events = {}
    end
  
    # scans commands for commands supports cmd.code
    # and envoke on_*cmd.code* method to every command, passed filter
    # 
    def parse( cmd )
      return unless @events[cmd.code]
      for command in @events[cmd.code]
        filter_passed = 
        if command.methods.include?(cmd.code + "_filter") 
          begin
            command.send((cmd.code + "_filter").to_sym,cmd)
          rescue => ex
            puts "Error in filter! #{ex}"
            print ex.backtrace.join("\n") #print returns nil
          end
        else
          true
        end

        if filter_passed
          puts "#{cmd.code} [#{cmd.src}] raises event in #{command.class}"

          filter_passed = 
          if command.methods.include?("post_filter")
            begin
              command.post_filter( cmd )
            rescue => ex
              puts "Error in post-filter! #{ex}"
              print ex.backtrace.join("\n")
            end
          else
            true
          end
        end

        if filter_passed
          puts "post-filter passed"
          begin
            command.send( ("on_" + cmd.code).to_sym, cmd )
          rescue => ex
            puts "Error! #{ex}"
            print ex.backtrace.join("\n")
          end
        end
      end
    end
  end
end
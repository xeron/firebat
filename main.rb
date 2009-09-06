require 'core/irc'
include FireBat

# load core modules

begin
  conn_id = ARGV[0].to_i || 0
rescue
  pits "Connection id must be Numeric value"
  exit;
end

bot_conf = $config['irc'][conn_id]
unless bot_conf
  puts "Config #{conn_id} not found."
  exit 
end
bot = IRC.new bot_conf
bot.connect
bot.rehash
puts "starting..."
bot.nickserv "identify #{bot_conf[:nspassword]}"
bot.multi_join(bot_conf[:channels])  
#bot.privmsg "#x-19-x" , "test: " + (Time.now + 1.year + 29.days).to_s

#puts "Starting REPL..."
#print "FireBat5>"
#STDOUT.flush
#while(STDIN.gets)
#  begin
#    p eval($_)
#  rescue SyntaxError => ex
#    puts "Error in command! #{ex}"
#    print ex.backtrace.join("\n")
#  rescue => ex
#    puts "Error in command! #{ex}"
#    print ex.backtrace.join("\n")
#  end
#  puts ""
#  print "FireBat5>"
#  STDOUT.flush
#end

bot.wait!
#classes = []
#
#Dir.foreach("modules") do |file|
#    if file =~ /^(.+)\.rb$/
#        mod = $1   
#        require_or_load 'modules/' + mod
#        unless classes.index(mod.camelize)
#            classes << mod.camelize
#        end
#    end
#end
#
#
#bots_streams = []
#
#$config['irc'].each do |bot_conf| 
#    bots_streams << Thread.new(bot_conf) do |bot_conf|
#        bot = IRC.new bot_conf    
#        bot.connect
#        bot.join "#x-19-x"
#        bot.privmsg "#x-19-x" , "test: " + (Time.now + 1.year + 29.days).to_s
#        
#        for klass in classes
#            eval(klass + 'Controller').new bot
#        end
#        
#        bot.wait!
#    end
#end
#
#bots_streams.each do |str|
#    str.join
#end

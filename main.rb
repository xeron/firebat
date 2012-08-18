$:.unshift File.dirname(__FILE__)
require 'core/irc'
include FireBat

# Load core modules
raise "Connection id must be numeric." if ARGV[0] && ARGV[0] !~ /\d+/
conn_id = ARGV[0].to_i || 0

# Load config
bot_conf = $config['irc'][conn_id]
unless bot_conf
  raise "Config #{conn_id} not found."
end

bot = IRC.new bot_conf
bot.connect
bot.rehash
puts "Starting..."
bot.nickserv "identify #{bot_conf[:nspassword]}"
bot.multi_join(bot_conf[:channels])

# bot.privmsg "#firebatbot" , "test: " + (Time.now + 1.year + 29.days).to_s

if ENV['FIREBAT_REPL'] == "1"
  puts "Starting REPL..."
  print "FireBat5>"
  STDOUT.flush
  while(STDIN.gets)
   begin
     p eval($_)
   rescue SyntaxError => ex
     puts "Error in command! #{ex}"
     print ex.backtrace.join("\n")
   rescue => ex
     puts "Error in command! #{ex}"
     print ex.backtrace.join("\n")
   end
   puts ""
   print "FireBat5>"
   STDOUT.flush
  end
end

bot.wait!

# classes = []

# Dir.foreach("modules") do |file|
#   if file =~ /^(.+)\.rb$/
#     mod = $1
#     require_or_load File.join("modules", mod)
#     unless classes.index(mod.camelize)
#       classes << mod.camelize
#     end
#   end
# end

# bots_streams = []

# $config['irc'].each do |bot_conf|
#   bots_streams << Thread.new(bot_conf) do |bot_conf|
#     bot = IRC.new bot_conf
#     bot.connect
#     bot.join "#x-19-x"
#     bot.privmsg "#x-19-x" , "test: " + (Time.now + 1.year + 29.days).to_s

#     for klass in classes
#       eval(klass + 'Controller').new bot
#     end

#     bot.wait!
#   end
# end

# bots_streams.each do |str|
#   str.join
# end

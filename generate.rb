comm = ARGV[0]
File.open("modules/#{comm}.rb",'w') do |f|
  f.puts "class #{comm} < FireBatCommand
  def on_privmsg( cmd )
    # insert code here 
  end
  
  def privmsg_filter( cmd )
    cmd.args(1,0) == \"!#{comm}\"
  end
end"
end

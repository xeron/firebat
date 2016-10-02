command = ARGV[0]

File.open(File.join('modules', "#{command}.rb"), 'w') do |f|
  f.puts <<~EOS
    class #{command} < FireBatCommand
      def on_privmsg(cmd)
        # insert code here
      end

      def privmsg_filter(cmd)
        cmd.args(1, 0) == "!#{command}"
      end
    end
  EOS
end

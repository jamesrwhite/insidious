require_relative '../lib/insidious'

insidious = Insidious.new(:pid_file => '/tmp/insidious.pid')

def app
  while true
    puts Time.now.utc
    sleep 1
  end
end

case ARGV.first
when 'start'
  insidious.start! { app }
when 'stop'
  insidious.stop!
when 'status'
  if insidious.running?
    puts 'insidious is running'
  else
    puts 'insidious is not running'
  end
when 'restart'
  insidious.restart! { app }
else
  puts "Usage: [start|stop|restart|status]"
end

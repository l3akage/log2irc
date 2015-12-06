module Log2irc
  class SyslogListener
    def initialize
      @bot = Log2irc.bot
      @channel = Log2irc.settings['snmp']['channel']
    end

    def start
      SNMP::TrapListener.new(Host: '0.0.0.0',
                             Port: Log2irc.settings['snmp']['port'] || 1062
                            ) do |manager|
        manager.on_trap_default do |trap|
          @bot.say(trap.inspect, @channel)
        end
      end
    end
  end
end

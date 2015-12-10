module Log2irc
  class SnmpListener
    def initialize
      @bot = Log2irc.bot
      @channel = Log2irc.settings['snmp']['channel']
    end

    def start
      SNMP::TrapListener.new(Host: '0.0.0.0',
                             Port: Log2irc.settings['snmp']['port'] || 1062
                            ) do |manager|
        manager.on_trap_default do |trap|
          msg = "#{trap.source_ip} "
          trap.each_varbind do |vb|
            msg += "#{vb.name}: #{vb.value}"
          end
          @bot.say(msg, @channel)
        end
      end
    end
  end
end

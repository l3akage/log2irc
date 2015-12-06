module Log2irc
  class SyslogListener
    def initialize
      @bot = Log2irc.bot
      @listener = UDPSocket.new
      @listener.bind('0.0.0.0', Log2irc.settings['syslog']['port'])
    end

    def start
      loop do
        begin
          data, meta = @listener.recvfrom(9000)
          parsed = SyslogProtocol.parse(data, meta[2])

          tag = parsed.tag if parsed.tag != 'unknown'
          channel, host = Channel.find(meta[2].to_s)

          message  = "#{Time.now.strftime('%H:%M:%S')} "
          message += "#{severity(parsed.severity_name)} "
          message += "#{StringIrc.new(host).bold} - #{tag} #{parsed.content}"

          next if Blacklist.blacklisted?(channel, "#{tag} #{parsed.content}")
          @bot.say(message, channel)
        rescue => e
          @bot.say("EXCEPTION: #{e.message} => #{e.backtrace.join("\n")}")
        end
      end
    end

    private

    def severity(s)
      s = 'error' if s == 'err'
      StringIrc.new("#{colorfy(s)} ".upcase).bold
    end

    def colorfy(severity)
      case severity
      when 'notice'
        return StringIrc.new(severity).light_blue
      when 'info'
        return StringIrc.new(severity).blue
      when 'warn'
        return StringIrc.new(severity).yellow
      when 'error', 'alert', 'crit', 'err', 'emerg'
        return StringIrc.new(severity).red
      else
        return StringIrc.new(severity).green
      end
    end
  end
end

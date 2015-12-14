module Log2irc
  class Watchdog
    def initialize
      @bot = Log2irc.bot
      @time = Log2irc.settings['watchdog']['time'] || 30
    end

    def start
      loop do
        begin
          Channel.channels.each do |_channel, hosts|
            hosts.each do |ip, data|
              next unless data[:last_log] && (Time.now.to_i - data[:last_log]) > @time * 60
              since = data[:last_log].nil? ? 'always' : "#{(Time.now.to_i - data[:last_log]) / 60} minutes"
              msg = "Watchdog: #{ip}(#{data[:hostname]}) is silent since #{since}"
              @bot.say(msg)
            end
          end
          sleep 10
        rescue => e
          @bot.say("WATCHDOG EXCEPTION: #{e.message} => #{e.backtrace.join("\n")}")
        end
      end
    end
  end
end

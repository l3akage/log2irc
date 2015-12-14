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
              next if data[:last_log].nil?
              if data[:watchdog].nil?
                next if (Time.now.to_i - data[:last_log]) < @time * 60
              else
                next if (Time.now.to_i - data[:last_log]) < data[:watchdog] * 60
              end
              msg = "Watchdog: #{ip}(#{data[:hostname]}) is silent since #{(Time.now.to_i - data[:last_log]) / 60} minutes"
              @bot.say(msg)
            end
          end
          sleep 5 * 60
        rescue => e
          @bot.say("WATCHDOG EXCEPTION: #{e.message} => #{e.backtrace.join("\n")}")
        end
      end
    end
  end
end

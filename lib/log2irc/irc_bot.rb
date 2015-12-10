require 'socket'

module Log2irc
  class IrcBot
    def initialize
      load_settings
      fail 'not configured' if @host.nil? || @channel.nil?
      @socket = TCPSocket.open(@host, @port)
      write "NICK #{@nick}"
      write "USER #{@nick} 0 * : #{@realname}"
    end

    def load_settings
      @host     = Log2irc.settings['irc']['host']
      @channel  = Log2irc.settings['irc']['channel']
      @port     = Log2irc.settings['irc']['port'] || 6667
      @nick     = Log2irc.settings['irc']['nick'] || 'log2irc'
      @realname = Log2irc.settings['irc']['realname'] || 'sysBot v0.1'
      @channels = [@channel]
      @state    = :disconnected
    end

    def write(msg)
      @socket.puts msg
    end

    def say(msg, channel = nil)
      return unless @state == :connected
      channel ||= @channel
      write "PRIVMSG #{channel} :#{msg}"
    end

    def join(channel)
      if @state == :connected
        write "JOIN #{channel}"
      else
        @channels << channel
      end
    end

    def part(channel)
      return if Log2irc.settings['irc']['channel'] == channel
      write "PART #{channel} :No hosts left"
    end

    def join_channels
      @channels.each do |channel|
        join(channel)
      end
    end

    def run
      until @socket.eof? do
        msg = @socket.gets("\r\n")

        unless (match = msg.match(/^PING :(.*)$/)).nil?
          write "PONG #{match[1]}"
          next
        end

        if msg.match(/#{@nick} MODE #{@nick}/)
          @state = :connected
          join_channels
          next
        end

        unless (match = msg.match(/PRIVMSG (#.+) :(.*)$/)).nil?
          handle_commands(match[1], match[2])
          next
        end
        puts msg.inspect
      end
    end

    def handle_commands(channel, command)
      # add word to channel blacklist
      match = command.match(/\!add (.*)$/)
      if match
        Blacklist.add(channel, match[1].strip)
        say("Added: #{match[1].strip}", channel)
        return
      end

      # remove word from channel blacklist
      match = command.match(/\!del (.*)$/)
      if match
        Blacklist.del(channel, match[1].strip)
        say("Removed: #{match[1].strip}", channel)
        return
      end

      # move host|ip to another channel
      match = command.match(/\!move (.*) (.*)$/)
      if match
        new_channel = match[2].strip
        new_channel = "##{new_channel}" unless new_channel.start_with?('#')
        Channel.move(new_channel, match[1].strip)
        say("Moved #{match[1].strip} to #{new_channel}", channel)
        return
      end

      # rename host|ip
      match = command.match(/\!rename (.*) (.*)$/)
      if match
        if Channel.rename(match[1].strip, match[2].strip)
          say("Renamed #{match[1].strip} to #{match[2].strip}", channel)
        else
          say("#{match[1].strip} not found", channel)
        end
        return
      end

      # update reverse dns of host|ip
      match = command.match(/\!refresh (.*)$/)
      if match
        res = Channel.refresh(match[1].strip)
        if res
          say("Refreshed #{match[1].strip} to #{res}", channel)
        else
          say("#{match[1].strip} not found", channel)
        end
        return
      end

      # set level
      match = command.match(/\!set (.*)$/)
      if match
        if Severity.list.keys.include?(match[1].strip)
          Severity.set(channel, match[1].strip)
          say("Set level to #{match[1].strip}", channel)
        else
          say('Unknown level', channel)
        end
        return
      end

      # list levels
      match = command.match(/\!list(.*)$/)
      if match
        say("Possible levels #{Severity.list.keys.join(', ')}", channel)
        return
      end
    end

    def quit
      write 'QUIT'
    end
  end
end

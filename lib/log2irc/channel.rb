module Log2irc
  class Channel
    class << self
      # hostname or ip
      def move(to, hostname_ip)
        if channels[to].nil?
          channels[to] = {}
          Log2irc.bot.join(to)
        end
        ip, hostname = remove(hostname_ip)
        channels[to][ip] = {
          hostname: hostname,
          last_log: Time.now.to_i
        }
        save_config
      end

      # hostname or ip
      def rename(hostname_ip, hostname)
        channels.each do |channel, hosts|
          hosts.each do |ip, data|
            next unless ip == hostname_ip || data[:hostname] == hostname_ip
            channels[channel][ip][:hostname] = hostname
            save_config
            return true
          end
        end
        false
      end

      # hostname or ip
      def refresh(hostname_ip)
        channels.each do |channel, hosts|
          hosts.each do |ip, data|
            next unless ip == hostname_ip || data[:hostname] == hostname_ip
            channels[channel][ip][:hostname] = resolv(ip)
            save_config
            return channels[channel][ip][:hostname]
          end
        end
        false
      end

      # hostname or ip
      def remove(hostname_ip)
        channels.each do |channel, hosts|
          hosts.each do |ip, data|
            next unless ip == hostname_ip || data[:hostname] == hostname_ip
            channels[channel].delete(ip)
            if channels[channel].empty?
              channels.delete(channel)
              Log2irc.bot.part(channel)
            end
            return [ip, data[:hostname]]
          end
        end
        nil
      end

      # hostname or ip
      def watchdog(hostname_ip, time)
        channels.each do |channel, hosts|
          hosts.each do |ip, data|
            next unless ip == hostname_ip || data[:hostname] == hostname_ip
            data[:watchdog] = time
            return [ip, data[:hostname]]
          end
        end
        nil
      end

      # ip
      def find(host_ip)
        channels.each do |channel, hosts|
          hosts.each do |ip, data|
            if ip == host_ip
              data[:last_log] = Time.now.to_i
              return [channel, data[:hostname]]
            end
          end
        end
        [Log2irc.settings['irc']['channel'], add_new_host(host_ip)]
      end

      def channels
        return @channels if @channels
        if File.exist?(file_path)
          @channels = YAML.load_file(file_path)
        else
          @channels = {}
        end
        @channels.each do |ch, _list|
          Log2irc.bot.join(ch)
        end
      end

      def add_new_host(host_ip)
        ch = Log2irc.settings['irc']['channel']
        channels[ch] = {} unless channels[ch]
        channels[ch][host_ip] = {
          hostname: resolv(host_ip),
          last_log: Time.now.to_i
        }
        save_config
        channels[ch][host_ip][:hostname]
      end

      def resolv(host_ip)
        Resolv.getname(host_ip)
      rescue
        host_ip
      end

      def save_config
        File.open(file_path, 'w') do |f|
          f.write channels.to_yaml
        end
      end

      def file_path
        File.join(Log2irc.path, '../config/channels.yml')
      end
    end
  end
end

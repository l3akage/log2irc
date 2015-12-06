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
        channels[to][ip] = hostname
        save_config
      end

      # hostname or ip
      def rename(hostname_ip, hostname)
        channels.each do |channel, hosts|
          hosts.each do |ip, oldhostname|
            next unless ip == hostname_ip || oldhostname == hostname_ip
            channels[channel][ip] = hostname
            save_config
            return true
          end
        end
        false
      end

      # hostname or ip
      def refresh(hostname_ip)
        channels.each do |channel, hosts|
          hosts.each do |ip, hostname|
            next unless ip == hostname_ip || hostname == hostname_ip
            channels[channel][ip] = resolv(ip)
            save_config
            return channels[channel][ip]
          end
        end
        false
      end

      # hostname or ip
      def remove(hostname_ip)
        channels.each do |channel, hosts|
          hosts.each do |ip, hostname|
            next unless ip == hostname_ip || hostname == hostname_ip
            channels[channel].delete(ip)
            if channels[channel].empty?
              channels.delete(channel)
              Log2irc.bot.part(channel)
            end
            return [ip, hostname]
          end
        end
      end

      # ip
      def find(host_ip)
        channels.each do |channel, hosts|
          hosts.each do |ip, hostname|
            return [channel, hostname || ip] if ip == host_ip
          end
        end
        add_new_host(host_ip)
        [Log2irc.settings['irc']['channel'], host_ip]
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
        channels[ch][host_ip] = resolv(host_ip)
        save_config
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

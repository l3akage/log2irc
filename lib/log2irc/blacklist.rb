module Log2irc
  class Blacklist
    class << self
      def add(channel, content)
        blacklist(channel).push(content)
        save_blacklist(channel)
      end

      def del(channel, content)
        blacklist(channel).delete(content)
        save_blacklist(channel)
      end

      def blacklisted?(channel, content)
        blacklist(channel).any? { |word| content.include?(word) }
      end

      def blacklist(channel)
        return @blacklists[channel] if @blacklists && @blacklists[channel]
        @blacklists = {} unless @blacklists
        if File.exist?(file_path(channel))
          @blacklists[channel] = YAML.load_file(file_path(channel))
        else
          @blacklists[channel] = []
        end
        @blacklists[channel]
      end

      def file_path(channel)
        File.join(Log2irc.path, "../config/blacklist-#{channel}.yml")
      end

      def save_blacklist(channel)
        File.open(file_path(channel), 'w') do |f|
          f.write blacklist(channel).to_yaml
        end
      end
    end
  end
end

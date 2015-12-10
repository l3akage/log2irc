module Log2irc
  class Severity
    class << self
      def set(channel, level)
        severities[channel] = value(level)
        save
      end

      def filter?(channel, level)
        value(level) > (severities[channel] || 7)
      end

      def severities
        return @severities if @severities
        @severities = YAML.load_file(file_path) if File.exist?(file_path)
        @severities ||= {}
      end

      def file_path
        File.join(Log2irc.path, '../config/severity.yml')
      end

      def save
        File.open(file_path, 'w') do |f|
          f.write @severities.to_yaml
        end
      end

      def list
        {
          'emerg' => 0,
          'alert' => 1,
          'crit' => 2,
          'err' => 3,
          'warn' => 4,
          'notice' => 5,
          'info' => 6,
          'debug' => 7
        }
      end

      def value(level)
        list[level.downcase] || 7
      end
    end
  end
end

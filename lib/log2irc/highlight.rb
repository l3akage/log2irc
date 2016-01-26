module Log2irc
  class Highlight
    class << self
      def add(content)
        highlight.push(content)
        save_highlights
      end

      def del(content)
        highlight.delete(content)
        save_highlights
      end

      def highlighted?(channel, severity, host, content)
        highlight.each do |word|
          next unless content.include?(word)
          SlackJob.new.async.perform("#{channel}: #{severity} #{host} - #{content}", word)
          return
        end
      end

      def highlight
        return @highlights if @highlights
        if File.exist?(file_path)
          @highlights = YAML.load_file(file_path)
        else
          @highlights = []
        end
        @highlights
      end

      def file_path
        File.join(Log2irc.path, "../config/highlights.yml")
      end

      def save_highlights
        File.open(file_path, 'w') do |f|
          f.write highlight.to_yaml
        end
      end
    end
  end
end

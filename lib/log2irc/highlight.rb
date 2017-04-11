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

      def add_ignore(host)
        ignored_hosts.push(host)
        save_highlights
      end

      def del_ignore(host)
        ignored_hosts.delete(host)
        save_highlights
      end

      def highlighted?(channel, severity, host, content)
        highlight.each do |word|
          next unless content.include?(word)
          next if ignored_hosts.include?(host)
          SlackJob.new.async.perform("#{channel}: #{severity} #{host} - #{content}", word)
          return
        end
      end

      def ignored_hosts
        return @ignored_hosts if @ignored_hosts
        if File.exist?(ignored_hosts_file_path)
          @ignored_hosts = YAML.load_file(ignored_hosts_file_path)
        else
          @ignored_hosts = []
        end
        @ignored_hosts
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

      def ignored_hosts_file_path
        File.join(Log2irc.path, "../config/ignored_host_highlights.yml")
      end

      def save_highlights
        File.open(file_path, 'w') do |f|
          f.write highlight.to_yaml
        end
        File.open(ignored_hosts_file_path, 'w') do |f|
          f.write ignored_hosts.to_yaml
        end
      end
    end
  end
end

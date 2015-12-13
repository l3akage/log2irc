require 'syslog_protocol'
require 'string-irc'
require 'syslog'
require 'socket'
require 'resolv'
require 'yaml'

require 'log2irc/syslog_listener'
require 'log2irc/blacklist'
require 'log2irc/severity'
require 'log2irc/watchdog'
require 'log2irc/version'
require 'log2irc/channel'
require 'log2irc/irc_bot'

module Log2irc
  module_function

  def start
    @bot = IrcBot.new
    trap('INT') do
      @bot.quit
      Channel.save_config
    end
    Thread.new { SyslogListener.new.start }
    Thread.new { Watchdog.new.start } if Log2irc.settings['watchdog']
    @bot.run
  end

  def settings
    @settings ||= YAML.load_file(File.join(path, '../config/config.yml'))
  end

  def bot
    @bot
  end

  def path
    File.dirname(File.expand_path(__FILE__))
  end
end

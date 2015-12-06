require 'syslog_protocol'
require 'string-irc'
require 'syslog'
require 'socket'
require 'resolv'
require 'snmp'
require 'yaml'

require 'log2irc/syslog_listener'
require 'log2irc/snmp_listener'
require 'log2irc/blacklist'
require 'log2irc/version'
require 'log2irc/channel'
require 'log2irc/irc_bot'

module Log2irc
  module_function

  def start
    @bot = IrcBot.new
    trap('INT') { @bot.quit }
    Thread.new { SyslogListener.new.start }
    Thread.new { SnmpListener.new.start }
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

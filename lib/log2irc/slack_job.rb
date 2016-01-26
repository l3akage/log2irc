module Log2irc
  class SlackJob
    include ::SuckerPunch::Job

    def perform(text, highlight)
      return unless Log2irc.settings['slack'] && Log2irc.settings['slack']['webhook']
      notifier = ::Slack::Notifier.new(Log2irc.settings['slack']['webhook'])
      notifier.channel  = Log2irc.settings['slack']['channel'] || '#syslog'
      notifier.username = Log2irc.settings['slack']['username'] || 'Syslog'

      text.gsub!(highlight, "*#{highlight}*")
      notifier.ping(text, icon_emoji: Log2irc.settings['slack']['icon'] || ':memo:')
    end
  end
end

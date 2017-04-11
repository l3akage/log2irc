# Log2irc

Syslog to IRC Gateway with message filtering

## Installation

1. `$ git clone https://github.com/l3akage/log2irc.git`
2. Change to the log2irc directory
3. Change into the config directory
4. `$ copy config-default.yml config.yml`
5. Edit configuration `$ $EDITOR config.yml`
6. Setup IPTables to direct syslog traffic to a port > 1024 `$ iptables -t nat -A PREROUTING -p udp --dport 514 -j REDIRECT --to-port 1514`

## Usage

`$ ./bin/log2irc`

Add string to blacklist*

`!add word`

Remove string from blacklist*

`!del word`

Move syslog from a host into another channel

`!move [hostname|ip] channel`

Set a hostname for an ip without reverse dns or override an existing hostname

`!rename [hostname|ip] hostname`

Remove host from channel list

`!remove [hostname|ip]`

Refresh the reverse dns of an ip

`!refresh [hostname|ip]`

List possible severity levels

`!list`

Set channel severity (hide messages with < severity)

`!set severity`

Set watchdog time for a host

`!watchdog [hostname|ip] [time in minutes]`

Add word to highlights list. If a message contains that word it gets posted to the Slack webhook

`!hadd word`

Remove word from highlights

`!hdel word`

Ignore highlights for host

`!hignore host`

Notice highlights for host again

`!hnotice host`


\*Blacklists are per channel


## Contributing

1. Fork it ( http://github.com/l3akage/log2irc/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

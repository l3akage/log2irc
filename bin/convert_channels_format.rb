#!/usr/bin/env ruby

require 'yaml'

channels_file = File.join(File.dirname(File.expand_path(__FILE__)), '../config/channels.yml')

unless File.exist?(channels_file)
  puts 'channels.yml not found'
  exit
end

@channels = YAML.load_file(channels_file)
@new_channels = {}

@channels.each do |channel, list|
  @new_channels[channel] = {}
  list.each do |ip, hostname|
    @new_channels[channel][ip] = {
      hostname: hostname,
      last_log: nil
    }
  end
end

File.open(channels_file, 'w') do |f|
  f.write @new_channels.to_yaml
end

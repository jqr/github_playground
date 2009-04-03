#!/usr/bin/env ruby

require 'rubygems'
require 'httparty'
require 'hpricot'
require 'active_support'

# TODO: real histograms

def breakdown(hash)
  multiplier = 60.to_f / hash.values.max

  hash.keys.sort { |a, b| hash[a] <=> hash[b] }.last(20).each do |key|
    value = hash[key]
    next unless value * multiplier > 1
    puts "%15s, %4i: " % [key, value] +  '*' * (value * multiplier)
  end
end

page = Hpricot.parse(HTTParty.get('http://gems.github.com/list.html'))

users = []
gems = []
versions = []
user_gem_counts = Hash.new(0)

gem_infos = (page / 'li').collect do |element|
  user, gem, version = element.inner_html.scan(/^(.*?)-(.*?) \((.*)\)/).first
  users << user
  gems << gem
  versions << version
  user_gem_counts[user] += 1
end

uniq_users = users.uniq
uniq_gems = gems.uniq

puts "Gem Stats:"
puts " * Total: #{gems.size}"
puts " * Unique: #{uniq_gems.size}"

puts "User Stats:"
puts " * Total: #{uniq_users.size}"
puts " * Average # of gems: #{gems.size.to_f / uniq_users.size}"
puts " * Most # of gems: #{user_gem_counts.values.max}"
breakdown(user_gem_counts)

version_counts = Hash.new(0)
versions.each do |version|
  version_counts[version] += 1
end

puts "Version Breakdown:"
breakdown(version_counts)

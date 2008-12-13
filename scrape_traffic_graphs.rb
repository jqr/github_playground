#!/usr/bin/env ruby

unless ARGV.size == 2
  puts "usage is scrape_traffic_graphs.rb <user> <output_file>"
  exit(1)
end

require 'rubygems'
require 'httparty'
require 'hpricot'

login = ARGV[0]

puts "fetching #{login}..."

user_data = HTTParty.get("http://github.com/api/v1/json/#{login}")['user']

File.open(ARGV[1], 'w') do |f|
  user_data['repositories'].each do |repository|
    project = repository['name']
    puts "  fetching #{project}..."
    page_data = HTTParty.get("http://github.com/#{login}/#{project}/graphs/traffic")
    page = Hpricot.parse(page_data)
    traffic_graph_img = (page / 'img[@alt="Google Chart"]').first
    f.write("<h2>#{project}</h2>\n")
    f.write(traffic_graph_img.to_s + "\n")
  end
end
#!/usr/bin/env ruby

if ARGV.size < 1
  puts "usage is scrape_traffic_graphs.rb <users>"
  exit(1)
end

require 'rubygems'
require 'httparty'
require 'hpricot'

ARGV.each do |login|
  puts "fetching #{login}'s projects"

  user_data = HTTParty.get("http://github.com/api/v1/json/#{login}")['user']
  output_filename = File.join(File.dirname(__FILE__), 'tmp', "#{login}.html")

  File.open(output_filename, 'w') do |f|
    repositories = [user_data['repositories']].flatten.compact
    repositories.each do |repository|
      project = repository['name']
      puts "  fetching #{project}..."
      page_data = HTTParty.get("http://github.com/#{login}/#{project}/graphs/traffic")
      page = Hpricot.parse(page_data)
      traffic_graph_img = (page / 'img[@alt="Google Chart"]').first
      f.write("<h2>#{project}</h2>\n")
      f.write(traffic_graph_img.to_s + "\n")
    end
  end

  system("open #{output_filename}")
end
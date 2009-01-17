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
    f.write("<html>")
    f.write("<head><title>#{login}'s Project Stats</title></head>")
    f.write("<body>")
    f.write(%Q{<h1><a href="#{user_data['url']}">#{login}</a>'s Project Stats</h1>\n})
    f.write(%Q{#{user_data['location']}, \n}) if user_data['location']
    f.write(%Q{<a href="mailto:#{user_data['email']}">#{user_data['email']}</a><br />\n}) if user_data['email']

    repositories = [user_data['repositories']].flatten.compact
    repositories.each_with_index do |repository, index|
      project = repository['name']
      puts "  [#{index + 1}/#{repositories.size}] fetching #{project}..."
      page_data = HTTParty.get("http://github.com/#{login}/#{project}/graphs/traffic")
      page = Hpricot.parse(page_data)
      traffic_graph_img = (page / 'img[@alt="Google Chart"]').first
      f.write(%Q{<h2><a href="#{repository['url']}">#{project}</a></h2>\n})
      f.write("#{repository['watchers']} watchers, #{repository['forks']} forks<br />\n")
      f.write("<p>#{repository['description']}</p>") if repository['description'].size > 0
      f.write(traffic_graph_img.to_s + "\n")
    end
    f.write("</body>")
    f.write("</html>")
  end

  system("open #{output_filename}")
end
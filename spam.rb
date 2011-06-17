require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'restclient'
require 'fileutils'

rss = open('http://sfbay.craigslist.org/search/cto?query=honda+civic&srchType=T&minAsk=&maxAsk=2200&format=rss').read

doc = Nokogiri::XML(rss)
items = doc.css("item")
items.each do |i|
  url   = i.attr('about')
  title = i.css("title").text
  text  = i.css('description').text
  pid   = File.basename(url).gsub('.html', '')
  fn    = File.expand_path(File.join(File.dirname(__FILE__), 'listings', "#{pid}.html"))

  if File.exist?(fn)
    FileUtil.touch(fn)
    next
  end

  if text =~ /375/
    File.open(fn, 'w') do |fh|
      fh.puts url
      fh.puts "\n"
      fh.puts title
      fh.puts text
    end

    # submit CL report
    #RestClient.post('http://localhost:5000/searches', {
    #                  :requestType => 'abuse-911persinfo',
    #                  :emailUserName => 'Jerry Cheung',
    #                  :userEmailAddress => 'jollyjerry@gmail.com',
    #                  :userEmailAddress2 => 'jollyjerry@gmail.com',
    #                  :area => "SF bay area",
    #                  :userEmailSubject => "911 Phone number constantly being called",
    #                  :userEmailBody => "They've listed my phone number on #{url}.\n" +
    #                  "I've had it taken down several times, but they continue to list it. " +
    #                  "Is there any way to close their account or screen out my phone number?"
    #                })

    # click prohibited
    100.times {
      sleep(rand(5))
      # puts 'clicking on prohibited'
      RestClient.get("http://sfbay.craigslist.org/flag/?flagCode=28&postingID=#{pid}")
    }
  end
end


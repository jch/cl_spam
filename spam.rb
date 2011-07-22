require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'rest-client'
require 'open-uri'
require 'fileutils'

# monkeypatch for convenience
class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end

begin
  url = 'http://sfbay.craigslist.org/search/cto?query=honda+civic&srchType=T&minAsk=&maxAsk=2200&format=rss'
  rss = open(url).read

  doc = Nokogiri::XML(rss)
  items = doc.css("item")
  items.each do |i|
    url   = i.attr('about')
    title = i.css("title").text
    text  = i.css('description').text
    pid   = File.basename(url).gsub('.html', '')
    fn    = File.expand_path(File.join(File.dirname(__FILE__), 'listings', "#{pid}.html"))

    if File.exist?(fn)
      FileUtils.touch(fn)
      next
    end

    if text =~ /375/
      File.open(fn, 'w') do |fh|
        fh.puts url
        fh.puts "\n"
        fh.puts title
        fh.puts text
      end

      # click prohibited
      100.times {
        sleep(rand(5))
        # puts 'clicking on prohibited'
        RestClient.get("http://sfbay.craigslist.org/flag/?flagCode=28&postingID=#{pid}")
      }
    end
  end
rescue Exception => e
  require 'hoptoad_notifier'
  require './config/hoptoad'
  HoptoadNotifier.notify(e) rescue nil
end

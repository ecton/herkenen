require 'hpricot'
require 'open-uri'

namespace :feed do
  desc "Update feeds"
  task :update, [:feed_id] do |task, args|
    if args.feed_id.nil?
      feeds = Feed.all
    else
      feeds = [Feed.get(args.feed_id)]
    end
    
    feeds.each do |feed|
      puts "Updating #{feed.title || feed.url}"
      
      begin
        xml = Hpricot(open(feed.url).read)
        
        channel = xml.at("channel")
        feed.title = channel.at("title").inner_html
        description = channel.at("itunes:summary") || channel.at("description")
        feed.description = description.inner_html unless description.nil?
        feed.language = channel.at("language").inner_html
        author = channel.at("itunes:author")
        feed.author = author.inner_html unless author.nil?
        explicit = channel.at("itunes:explicit")
        feed.explicit = nil
        feed.explicit = explicit.inner_html != "no" unless explicit.nil?
        keywords = channel.at("itunes:keywords")
        feed.keywords = keywords.inner_html.split(",").collect{|k| k.strip} unless keywords.nil?
        feed.save
        
        
        channel.search("item").each do |item|
          guid = item.at("guid").inner_html
          enclosure = item.at("enclosure")
          next if enclosure.nil?
          puts "Found enclosure type: #{enclosure['type']}"
          next if enclosure['type'] != 'audio/mpeg'

          entry = FeedEntry.by_feed_and_guid(:key => [feed.id, guid]).first
          entry = FeedEntry.new(:feed_id => feed.id, :guid => guid) if entry.nil?
          
          entry.mp3_url = enclosure['url']
          entry.size = enclosure['length'].to_i
          duration = item.at('itunes:duration')
          entry.duration = duration.inner_html unless duration.nil?
          
          entry.title = item.at("title").inner_html
          begin
            entry.permalink = item.at("link").next.to_s
          rescue
          end
          description = channel.at("itunes:summary") || channel.at("description")
          entry.description = description.inner_html unless description.nil?
          entry.date = Time.parse(item.at("pubdate").inner_html)
          keywords = item.at("itunes:keywords")
          entry.keywords = keywords.inner_html.split(",").collect{|k| k.strip} unless keywords.nil?
          entry.save
          
          # TODO: Push to subscribers
        end
      rescue Exception => exc
        puts "- Error updating feed #{exc}"
      end
    end
  end
  
  desc "Add a feed"
  task :add, [:url] do |task, args|
    feed = Feed.new(:url => args.url)
    feed.save
    
    puts "New ID: #{feed.id}"
  end
end
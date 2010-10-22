module Herkenen
  module Feeds
    def self.update_all
      Feed.all.each{|f| update(f)}
    end
    
    def self.update(feed)
      puts "Updating #{feed.title || feed.url} - #{feed.id}"
      
      begin
        xml = Hpricot(open(feed.url).read)
        
        channel = xml.at("channel")
        oldfeed = feed.to_hash.clone
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
        feed.pic_url = (channel.at("itunes:image") || {})['href']
        feed.save if oldfeed != feed.to_hash
        
        
        channel.search("item").each do |item|
          guid = item.at("guid").inner_html
          enclosure = item.at("enclosure")
          next if enclosure.nil?
          next if enclosure['type'] != 'audio/mpeg'

          entry = FeedEntry.by_feed_and_guid(:key => [feed.id, guid]).first
          entry = FeedEntry.new(:feed_id => feed.id, :guid => guid) if entry.nil?
          
          oldentry = entry.to_hash.clone
          
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
          if entry.date > Time.now
            entry.date = nil
          end
          keywords = item.at("itunes:keywords")
          entry.keywords = keywords.inner_html.split(",").collect{|k| k.strip} unless keywords.nil?
          if oldentry != entry.to_hash
            entry.save
            puts "Saving entry #{entry.id}"
          end
          
          # TODO: Push to subscribers
        end
      rescue Exception => exc
        puts "- Error updating feed #{exc}"
      end
    end
  end
end

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
      Herkenen::Feeds.update(feed)
    end
  end
  
  desc "Add a feed"
  task :add, [:url] do |task, args|
    feed = Feed.new(:url => args.url)
    feed.save
    
    puts "New ID: #{feed.id}"
  end
end
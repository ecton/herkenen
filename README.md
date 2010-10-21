Herkenen
========

Herkenen is a tool aimed at bridging podcast listening across platforms in a seamless way. The server will keep track of updating feeds, keeping track of played statuses and positions, and providing a simple API to clients to keep everything up-to-date.

Architecture
============

Technologies
------------
* [sinatra](http://sinatrarb.com/)
* [CouchDB](http://couchdb.apache.org/)
* [couchrest](http://github.com/jchris/couchrest)
* [simple-rss](http://simple-rss.rubyforge.org/)

Data Model
----------

* __User__
  
  The user entity encompasses an email address/password hash combination, and a list of feeds that it is subscribed to.
  
* __Feed__
  
  The feed entity wraps a single RSS feed's information. This entity is not associated with any particular user.
  
* __FeedEntry__
  
  The feed entry entity wraps a single "article" or podcast from a feed. This is not built into the Feed entity purely for size concerns -- it would be nice to store all historical feed entries to allow historical browsing.
  
* __UserFeedEntry__

  This entity maps a FeedEntry and User, and associates status information such as played or current position in the file. It may also encompass ratings, comments, notes, or who knows what else.
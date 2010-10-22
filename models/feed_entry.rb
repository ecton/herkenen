class FeedEntry < CouchRest::ExtendedDocument
  use_database DB
  property :feed_id
  property :guid
  property :permalink
  property :mp3_url
  property :duration
  property :title
  property :description
  property :size
  property :date, :cast_as => 'Time'
  property :keywords, :cast_as => ['String']
  
  timestamps!
  
  view_by :feed_and_guid, {:map => "
      function (doc) {
        if (doc['couchrest-type'] == 'FeedEntry') {
          emit([doc['feed_id'],doc['guid']], null);
        }
      }
    "
  }
  
  view_by :feed_id
  view_by :keyword, {:map => "
      function(doc) {
        if (doc['couchrest-type'] == 'Feed' && doc['keywords']) {
          doc['keywords'].forEach(function (kw) {
            emit(kw, null);
          });
        }
      }
    "}
    
  view_by :date, {  :map => "
      function (doc) {
        if (doc['couchrest-type'] == 'FeedEntry') {
          emit(doc['date'] || doc['created_at'], null);
        }
      }
    "
  }
end

@entities << FeedEntry
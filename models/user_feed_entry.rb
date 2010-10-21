class UserFeedEntry < CouchRest::ExtendedDocument
  use_database DB
  property :feed_id
  property :feed_entry_id
  property :user_id
  property :date, :cast_as => 'Time'
  
  property :percent_complete
  property :current_offset
  
  view_by :user_id
  view_by :incomplete_user_id, {
    :map => "function (doc){
      if (doc['couchrest-type'] == 'UserFeedEntry') {
        if (doc['percent_complete'] < 100) {
          emit(doc['user_id'], null);
        }
      }
    }"
  }
end

@entities << UserFeedEntry
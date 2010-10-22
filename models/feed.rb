class Feed < CouchRest::ExtendedDocument
  use_database DB
  property :url
  property :pic_url
  property :title
  property :description
  property :language
  property :author
  property :explicit
  
  property :keywords, :cast_as => ['String']
  
  timestamps!
  
  view_by :url
  view_by :language
  view_by :keyword, {:map => "
      function(doc) {
        if (doc['couchrest-type'] == 'Feed' && doc['keywords']) {
          doc['keywords'].forEach(function (kw) {
            emit(kw, null);
          });
        }
      }
    "}
end

@entities << Feed
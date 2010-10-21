require 'digest/sha1'

class User < CouchRest::ExtendedDocument
  use_database DB
  property :email
  property :password_hash
  property :feeds, :cast_as => ['UserFeed']
  
  view_by :email
  view_by :feed_ids, {:map => "
      function(doc) {
        if (doc['couchrest-type'] == 'User' && doc['feeds']) {
          doc['feeds'].forEach(function (feed) {
            emit(feed['feed_id'], null);
          });
        }
      }
    "}
  
  def self.hash_password(password)
    Digest::SHA1.hexdigest("6-eKegucazevathespec-*bAxus3uRa77_ac#7xu@!ahe-e_aprapruhu=uthume" + password + "6-eKegucazevathespec-*bAxus3uRa77_ac#7xu@!ahe-e_aprapruhu=uthume")
  end
end

class UserFeed < Hash
  include CouchRest::CastedModel
  
  property :feed_id
  property :tags, :cast_as => ['String']
  property :rating
  property :review
end

@entities << User
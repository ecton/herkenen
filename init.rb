require 'rubygems'
require 'couchrest'
require 'couchrest_extended_document'
require 'yaml'
require 'sinatra/base'

RACK_ENV = ENV['RACK_ENV'] || "development"

ROOT_DIR = File.dirname(__FILE__)
def root_path(*args)
  File.join(ROOT_DIR, *args)
end

def settings(key)
  @settings ||= YAML.load_file(root_path("settings.yml"))[RACK_ENV.to_sym]
  return @settings[key]
end

@entities = []
DB = CouchRest.database!("http://#{settings(:server)[:domain]}:#{settings(:server)[:port]}/#{settings(:storage)[:dbname]}")
require root_path("models/user.rb")
require root_path("models/feed.rb")
require root_path("models/feed_entry.rb")
require root_path("models/user_feed_entry.rb")

require root_path('lib','herkenen.rb')

require root_path('routes/main.rb')
require root_path('helpers/main.rb')
require root_path('routes/api.rb')

Main.run! if $0 == __FILE__
class Main < Sinatra::Base
  set :app_file, __FILE__
  set :root, root_path
  set :encoding => "utf-8"
  
  use Rack::Session::Cookie
  use Rack::ShowExceptions if RACK_ENV != "production"
  
  before do
    headers 'Content-Type' => 'text/html; charset=utf-8'
    puts "here"
  end 
  
  get "/" do
    return "Hello, world!"
  end
end
class Main < Sinatra::Base
  set :app_file, __FILE__
  set :root, root_path
  set :encoding => "utf-8"
  
  use Rack::Session::Cookie
  use Rack::ShowExceptions if RACK_ENV != "production"
  
  before do
    headers 'Content-Type' => 'text/html; charset=utf-8'
  end 
  
  get "/" do
    @entries = FeedEntry.by_date(:descending => true, :limit => 10)
    @feeds = {}
    Feed.all.each{|f| @feeds[f.id] = f}
    
    haml :recent
  end

  get "/podcast/:id" do
    @entry = FeedEntry.get(params[:id])
    params[:title] = @entry.title
    @feed = Feed.get(@entry.feed_id)
    
    haml :podcast
  end
  
  get "/login" do
    haml :login
  end
  
  post "/login" do
    if login_user(params[:email], params[:password])
      redirect "/"
    else
      params[:error] = "Unknown username or password."
      haml :login
    end
  end

  post "/signup" do
    if params[:password] != params[:password2]
      params[:error] = "Confirmation password did not match, please try again."
    elsif !create_user(params[:email], params[:password])
      params[:error] = "An account is already registered with that email address"
    end
    
    if params[:error]
      haml :login
    else
      redirect "/"
    end
  end
end
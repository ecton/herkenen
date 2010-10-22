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
    check_user
    @entries = FeedEntry.by_date(:descending => true, :limit => 10)
    @feeds = {}
    @list_name = "Recent Podcasts"
    Feed.all.each{|f| @feeds[f.id] = f}
    
    haml :list
  end

  get "/podcast/:id" do
    check_user
    @entry = FeedEntry.get(params[:id])
    params[:title] = @entry.title
    @feed = Feed.get(@entry.feed_id)
    
    haml :podcast
  end

  post "/podcast/:id/progress" do
    p params
    check_user
    ufe = UserFeedEntry.by_user_and_feed_entry_id(:key => [@user.id, params[:id]]).first
    return {:error => true}.to_json if ufe.nil?
    
    ufe.current_offset = params[:offset].to_f
    ufe.total_length = params[:total].to_f
    ufe.percent_complete = (ufe.current_offset.to_f / ufe.total_length * 100).to_i
    ufe.save
    
    return {:error => false}.to_json
  end

  get "/feed/:id" do
    check_user
    @feed = Feed.get(params[:id])
    params[:title] = @feed.title
    @entries = FeedEntry.by_feed_id(:key => params[:id]).sort{|a,b| (b.date || b.created_at) <=> (a.date || a.created_at)}

    haml :feed
  end
  
  get "/save/:id" do
    check_user
    if @user
      p "Got user, looking up feed"
      entry = FeedEntry.get(params[:id])
      ufe = UserFeedEntry.by_user_and_feed_entry_id(:key => [@user.id, entry.id]).first
      if ufe.nil?
        p "Saving new user entry"
        ufe = UserFeedEntry.new
        ufe.user_id = @user.id
        ufe.feed_entry_id = entry.id
        ufe.feed_id = entry.feed_id
        ufe.save
      end
    end
    redirect request['HTTP_REFERRER'] || "/"
  end
  
  get "/playlist" do
    check_user
    redirect "/login" if @user.nil?
    
    @entries = UserFeedEntry.by_incomplete_user_id(:key => @user.id).sort{|a,b| b.created_at <=> a.created_at}.collect{|fe| FeedEntry.get(fe.feed_entry_id)}
    @feeds = {}
    @list_name = "Your Playlist"
    Feed.all.each{|f| @feeds[f.id] = f}
    
    haml :list
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
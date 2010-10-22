class Main
  helpers do
    def relative_time(time)
      now = Time.now
      delta = now - time
      delta = delta.to_i
      str = ""
      days = delta / 24 / 60 / 60
      delta -= days * 24 * 60 * 60
      if days > 6
        return time.strftime("%b %d")
      elsif days > 1
        return days.to_s + " days ago"
      elsif days == 1
        return "a day ago"
      end
      
      hours = delta / 60 / 60
      delta -= hours * 60 * 60
      if hours > 1
        return hours.to_s + " hours ago"
      elsif hours == 1
        return "an hour ago"
      end
      minutes = delta / 60
      if minutes > 1
        return minutes.to_s + " minutes ago"
      elsif minutes == 1
        return "a minute ago"
      else
        return "just now"
      end
    end
    
    def set_user_cookies
      if @user
        response.set_cookie("uid", {
          :path => "/",
          :expires => Time.now + 30.days,
          :httponly => true,
          :value => @user.id
        })

        response.set_cookie("challenge", {
          :path => "/",
          :expires => Time.now + 30.days,
          :httponly => true,
          :value => User.hash_password(@user.id + @user.password_hash)
        })
        
        return true
      else
        response.set_cookie("uid", {
          :path => "/",
          :expires => Time.now - 30.days,
          :httponly => true,
          :value => ""
        })

        response.set_cookie("challenge", {
          :path => "/",
          :expires => Time.now - 30.days,
          :httponly => true,
          :value => ""
        })
        
        return false
      end
    end
    
    def create_user(email, password)
      @user = nil
      
      user = User.by_email(:key => email.downcase).first
      return set_user_cookies unless user.nil?
      @user = User.new
      @user.email = email.downcase
      @user.password_hash = User.hash_password(password)
      @user.save
      
      return set_user_cookies
    end
    
    def login_user(email, password)
      @user = nil
      
      user = User.by_email(:key => email.downcase).first
      return set_user_cookies if user.nil?
      return set_user_cookies if user.password_hash != User.hash_password(password)
      @user = user
      
      response.set_cookie("uid", {
        :path => "/",
        :expires => Time.now + 30.days,
        :httponly => true,
        :value => @user.id
      })
      
      return set_user_cookies
    end
      
    def check_user
      @user = nil
      
      return set_user_cookies if request.cookies['uid'].nil? || request.cookies['challenge'].nil?
      user = User.get(request.cookies['uid'])
      return set_user_cookies if request.cookies['challenge'] != User.hash_password(user.id + user.password_hash)
      @user = user
      
      return set_user_cookies
    end
    
    def user_playlist_status(entry)
      return nil if @user.nil?
      
      ufe = UserFeedEntry.by_user_and_feed_entry_id(:key => [@user.id, entry.id]).first
      return nil if ufe.nil?
      
      return ufe.percent_complete || 0
    end

    def user_playlist_offset(entry)
      return nil if @user.nil?

      ufe = UserFeedEntry.by_user_and_feed_entry_id(:key => [@user.id, entry.id]).first
      return nil if ufe.nil?

      return ufe.current_offset || 0
    end
  end
end
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
    
    def create_user(email, password)
      user = User.by_email(:key => email.downcase).first
      return false unless user.nil?
      @user = User.new
      @user.email = email.downcase
      @user.password_hash = User.hash_password(password)
      @user.save
      return true
    end
    
    def login_user(email, password)
      user = User.by_email(:key => email.downcase).first
      return false if user.nil?
      return false if user.password_hash != User.hash_password(password)
      @user = user
      return true
    end
    
    def user_identity
      return nil if request.cookies['uid'].nil? || request.cookies['challenge'].nil?
      user = User.by_email(request.cookies['uid'])
      
    end
  end
end
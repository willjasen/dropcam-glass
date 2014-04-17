class User < ActiveRecord::Base
  validates :email, :refresh_token, :oauth_token, presence: true

  def self.get_credentials(user_id)
    user = User.find(user_id)

   if user
     # Get the token and refresh as a hash
     hash = {email: user.email, refresh_token: user.refresh_token}
   end
 end
end

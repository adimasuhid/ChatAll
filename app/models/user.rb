class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  #devise :omniauthable
  # Setup accessible (or protected) attributes for your model
    attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid, :oauth_token, :oauth_expires_at

  def self.from_omniauth(auth)
  where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
    user.provider = auth.provider
    user.uid = auth.uid
    user.oauth_token = auth.credentials.token
    user.oauth_expires_at = Time.at(auth.credentials.expires_at)
    user.save!
    end
  end

	def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
	  user = User.where(:provider => auth.provider, :uid => auth.uid).first
	  unless user
	    user = User.create(
	                         provider:auth.provider,
	                         uid:auth.uid,
	                         email:auth.info.email,
	                         password:Devise.friendly_token[0,20],
                           oauth_token:auth.credentials.token,
                           oauth_expires_at:Time.at(auth.credentials.expires_at)
	                         )
      #user.ensure_authentication_token!
      #added extra to create authentication for user
     
	  end
	  user
	end

end

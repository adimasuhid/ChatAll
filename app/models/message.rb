class Message < ActiveRecord::Base

	def self.connect (auth)
  		sender_chat_id = "-#{auth.uid}@chat.facebook.com"
  		client = Jabber::Client.new(Jabber::JID.new(sender_chat_id))
        #client.close
        if client.is_connected?()
          client.close
        end
        client.connect
        puts "connected"
        client.auth_sasl(Jabber::SASL::XFacebookPlatform.new(client,
           '434244103306527', 
           auth.oauth_token,
           'd74e401774a93b7cd2c07c7ad943308e'), nil)   
        client
  	end	

end

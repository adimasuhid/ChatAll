class MessagesController < ApplicationController
  # GET /messages
  # GET /messages.json

  require 'xmpp4r_facebook'
  require 'xmpp4r'

  def index
    @messages = Message.all

    #refactor to own controller
    #@graph = Koala::Facebook::API.new(current_user.oauth_token)
    #@chats = @graph.fql_query("SELECT author_id,message_id,body FROM message WHERE thread_id in (SELECT thread_id FROM thread WHERE folder_id = 0 and '100000192703202' IN recipients limit 1)")

    @graph = Koala::Facebook::API.new(current_user.oauth_token)
    @friends = @graph.get_connections("me", "friends")

    respond_to do |format|
      format.html # index.html.erb
      format.js  
      format.json { render json: @messages }
    end
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    @message = Message.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @message }
    end
  end

  # GET /messages/new
  # GET /messages/new.json
  def new
    @message = Message.new

    @graph = Koala::Facebook::API.new(current_user.oauth_token)
    @friends = @graph.get_connections("me", "friends")

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @message }
    end
  end

  # GET /messages/1/edit
  def edit
    @message = Message.find(params[:id])
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(params[:message])
      #sender_chat_id = "-#{@user}@chat.facebook.com"
      #receiver_chat_id = "-#{@user}@chat.facebook.com"

#refactor to own controller
receiver_id = @message.receiver_id
sender_chat_id = "-#{current_user.uid}@chat.facebook.com"
receiver_chat_id = "-#{receiver_id}@chat.facebook.com"
message_body = @message.message_body
message_subject = @message.message_subject


 
jabber_message = Jabber::Message.new(receiver_chat_id, message_body)
jabber_message.subject = message_subject
      #chat client connect
      
        client = Jabber::Client.new(Jabber::JID.new(sender_chat_id))
        #client.close
        if client.is_connected?()
          client.close
        else
        client.connect
        puts "connected"
        client.auth_sasl(Jabber::SASL::XFacebookPlatform.new(client,
           '434244103306527', 
           current_user.oauth_token,
           'd74e401774a93b7cd2c07c7ad943308e'), nil)
        client.send(jabber_message)

        #playing with message callback for retrieving messages
        mainthread = Thread.current
        puts "mainthread established"
        client.add_message_callback do |m|
          if m.type != :error
            puts "m.type ok"
            m2 = Jabber::Message.new(m.from, "You sent: #{m.body}")
            m2.type = m.type
            client.send(m2)
            if m.body == 'exit'
              m2 = Jabber::Message.new(m.from, "Exiting ...")
              m2.type = m.type
              client.send(m2)
              mainthread.wakeup
            end
          end
        end
        Thread.stop
        client.close
        end

    respond_to do |format|
      if @message.save
        format.html { redirect_to @message, notice: "Connected ! Sent message to #{sender_chat_id.strip.to_s}." }
        format.json { render json: @message, status: :created, location: @message }
      else
        format.html { render action: "new" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /messages/1
  # PUT /messages/1.json
  def update
    @message = Message.find(params[:id])

    respond_to do |format|
      if @message.update_attributes(params[:message])
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message = Message.find(params[:id])
    @message.destroy

    respond_to do |format|
      format.html { redirect_to messages_url }
      format.json { head :no_content }
    end
  end

  def chatview
    @message = Message.new(:receiver_id => params[:receiver_id])

    puts "got in"

    @graph = Koala::Facebook::API.new(current_user.oauth_token)
    @chats = @graph.fql_query("SELECT author_id,message_id,body FROM message WHERE thread_id in (SELECT thread_id FROM thread WHERE folder_id = 0 and #{@message.receiver_id} IN recipients)")

    respond_to do | format |  
      format.js  
    end
  end
end

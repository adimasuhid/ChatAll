ChatAll 

ChatAll is an integrated chat client that combines Facebook, SMS and Email for easier chatting transition. As of last commit, only the Facebook chat is functional. It uses Devise-Omniauth for Facebook connection, xmpp4r-facebook for sending messages and koala for graph and fql.

Install

Download the zip file and add it in the Sites folder.
Bundle install to update the gems.
Rake db:migrate to migrate all models.

Run

Go to /users/signup/ to register your Facebook account. It will be redirected to the chat client afterwards.

Note

This client is my first RoR project and it needs a lot of refactoring. Use at your own peril. Let me know if you were able to do some upgrades, I would greatly appreciate. Thanks!


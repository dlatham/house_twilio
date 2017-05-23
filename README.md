# House Twilio
-----------
A rails application that responds to Twilio SMS requests and does helpful things around the house. I was tired of using the multiple different UIs for everyone's proprietary mobile controller for there home automation thingy so I used a standard UI that we're all used to... Text messages.

The other beauty of using SMS is that you can invite people with multiple phone numbers which gives them temporary or permanent access to the house etcetera.

### Currently supports:
  - Basic ISY-994i PRO/IR integration
  - Simple authentication via inbound phone # and unique identifiers
  - Initial support for IP camera screengrabs via MMS
  - Basic user roles and new user invites
  - Ability to change response pleasantries based on time of day
  - Basic request logging
  - A basic admin UI available at /login

### Needs to support in the future:
 - Ability to maintain a multiple message conversation thread
 - More robust logs and filtering
 - Apartment switching and robust user roles
 - Two factor auth
 - A better home automation object model
 - Ability to proactively send messages when something changes at home

### Oh, and about environment variables...

Currently, a lot of the private stuff (usernames, passwords, URLs, etc) are stored as environment variables in the .env root file for development and server envvironment variables for production. They are referenced throughout the code but there are quite a few required to run this sucker and I don't have any of them documented becuse the code is so custom and single-purpose right now. I'll fix that eventually.

### Lastly, a Twilio account...
You'll need one. And the SMS webhook will need to be pointed at the /sms route to hit the API. The application reads the standard POST variables provided by Twilio's SMS service to recognize the user and understand how to respond.

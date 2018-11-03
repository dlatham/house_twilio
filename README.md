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

Environment Variables:
```
CAM_PASSWORD:             CAMERA_PASSWORD
CAM_USER:                 CAMERA_USER
DRIVEWAY_CAMERA_URL:      URL_TO_DRIVEWAY_CAMERA_PICTURE
FRONT_CAMERA_URL:         URL_TO_FRONT_CAMERA_PICTURE
ISY_HOST:                 BASE_URL_TO_ISY
ISY_PASSWORD:             
ISY_USER:                 
LVRM_CAMERA_URL:          URL_TO_LIVING_ROOM_CAMERA_PICTURE
SECRET_KEY_BASE:          
SECRET_TOKEN:             TWILIO_TOKEN
SID:                      TWILIO_SID
WIFI_PASSWORD:            WIFI_PASSWORD_FOR_REQUESTS
```

### Installation
 - Clone the repository locally
 - Create your .env file at the root
 - Bundle Install
 - Create and migrate the database `rake db:create` and `rake db:migrate`
 - Seed the database: `rake db:seed`
 - Launch the server

### Lastly, a Twilio account...
You'll need one. And the SMS webhook will need to be pointed at the /sms route to hit the API. The application reads the standard POST variables provided by Twilio's SMS service to recognize the user and understand how to respond.



## Changelog
----------------
 - 0.1 : First beta version
 - 0.2 : Added git-version-bump gem and the ability to check version w/ notes via SMS
   - 2 Add releases and the ability to reference the release from SMS



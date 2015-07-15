class TwilioController < ApplicationController
  require 'twilio-ruby'
  require 'nokogiri'
  require 'open-uri'

  def temperature
    # get temperature from all thermostat nodes
    @doc = Nokogiri::XML(open("#{ENV['ISY_HOST']}/rest/status",
                              http_basic_authentication: [ENV['ISY_USER'], ENV['ISY_PASSWORD']]))
    # I HARDCODED THE ADDRESSES HERE, PROBABLY NOT THE BEST IDEA
    @thefile = @doc.xpath("nodes/node[@id='14 F7 28 1']/property[@id='ST']/@formatted | nodes/node[@id='23 40 20 1']/property[@id='ST']/@formatted")
    return "it's currently #{@thefile[0].value.to_f.round(0)} in the living room and #{@thefile[1].value.to_f.round(0)} in the master bath"
  end

  def sms
    # INCOMING MESSAGE FROM TWILIO STARTS HERE
    # FIRST WE CHECK IF IT IS A REGISTERED SENDER
    @user = User.find_by phone: params[:From]
    if @user.blank?
      twiml = Twilio::TwiML::Response.new do |r|
        r.Message "Oh hey there stranger! You need to be registered in order to text the house."
      end
      render text: twiml.text
    else
      @greeting = "Whats up #{@user.fname}? "
      @message = temperature
      twiml = Twilio::TwiML::Response.new do |r|
        r.Message @greeting + @message
      end
      render text: twiml.text
    end
  end

  def help
    # THE HELP FILE - SHOULD BE UPDATED REGULARLY WITH NEW METHODS
    return "possible commands include: Temp"
  end
end

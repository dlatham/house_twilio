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
    @message = temperature
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message @message
    end
    render text: twiml.text
  end
end

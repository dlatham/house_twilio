class TwilioController < ApplicationController
  require 'twilio-ruby'
  require 'nokogiri'
  require 'open-uri'
  require 'net/http'

  def lightsdown
    uri = URI("#{ENV['ISY_HOST']}/rest/nodes/40906/cmd/DON")
    Net::HTTP.start(uri.host,uri.port) do |http|
      req = Net::HTTP::Get.new(uri.path)
      req.basic_auth ENV['ISY_USER'], ENV['ISY_PASSWORD']
      response = http.request(req)
    end
    return "Let me set the mood for you..."
  end


  def unlockDoor
    uri = URI("#{ENV['ISY_HOST']}/rest/programs/0013/runThen")
    Net::HTTP.start(uri.host,uri.port) do |http|
      req = Net::HTTP::Get.new(uri.path)
      req.basic_auth ENV['ISY_USER'], ENV['ISY_PASSWORD']
      response = http.request(req)
    end
    return "Unlocked and buzzed in. Did you make it?"
  end

  def lockDoor
    uri = URI("#{ENV['ISY_HOST']}/rest/nodes/ZW002_1/cmd/SECMD/1")
    Net::HTTP.start(uri.host,uri.port) do |http|
      req = Net::HTTP::Get.new(uri.path)
      req.basic_auth ENV['ISY_USER'], ENV['ISY_PASSWORD']
      response = http.request(req)
    end
    return "The front door is locked!"
  end

  def temperature
    # get temperature from all thermostat nodes
    @doc = Nokogiri::XML(open("#{ENV['ISY_HOST']}/rest/status",
                              http_basic_authentication: [ENV['ISY_USER'], ENV['ISY_PASSWORD']]))
    # I HARDCODED THE ADDRESSES HERE, PROBABLY NOT THE BEST IDEA
    @thefile = @doc.xpath("nodes/node[@id='14 F7 28 1']/property[@id='ST']/@formatted | nodes/node[@id='23 40 20 1']/property[@id='ST']/@formatted")
    return "it's currently #{@thefile[0].value.to_f.round(0)} in the living room and #{@thefile[1].value.to_f.round(0)} in the master bath"
  end


  def gatecam_proxy
    image_url = ENV['FRONT_CAMERA_URL']
    response.headers['Cache-Control'] = "public, max-age=#{84.hours.to_i}"
    response.headers['Content-Type'] = 'image/jpg'
    response.headers['Content-Disposition'] = 'inline'
    render :text => open(image_url, "rb", http_basic_authentication: [ENV['CAM_USER'], ENV['CAM_PASSWORD']]).read
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

      # USER WAS FOUND, LET'S START PARSING
      # START NEW MESSAGE PARSING HERE!!!!
      @in = params[:Body].downcase
      case
        when @in.include?("help")
          @message = help
        when @in.include?("temp") || @in.include?("temperature") || @in.include?("hot") || @in.include?("cold")
          @message = temperature
        when @in.include?("front") || @in.include?("frontdoor") || @in.include?("gate") || @in.include?("doorbell")
          @message = "Here's what the gate camera say..."
          @media = ENV['BASE_URL'] + '/images/gate.jpg'
        when @in.include?("drive") || @in.include?("driveway") || @in.include?("cars") || @in.include?("street")
          @message = "Here's what the driveway camera say..."
          @media = ENV['DRIVEWAY_CAMERA_URL']
        when @in.include?("living") || @in.include?("room") || @in.include?("couch") || @in.include?("kitchen")
          @message = "Here's what the living room camera say..."
          @media = ENV['LVRM_CAMERA_URL']
        when @in.include?("lights") || @in.include?("down")
          @message = lightsdown
        when @in.include?("unlock") || @in.include?("buzz")
          @message = unlockDoor
        when @in.include?("lock")
          @message = lockDoor
        else
          @message = "I'm not sure I know what you are saying dude."
      end
      @greeting = "Whats up #{@user.fname}? "

      if @media.nil?
        twiml = Twilio::TwiML::Response.new do |r|
          r.Message @greeting + @message
        end
        render text: twiml.text
      else
        twiml = Twilio::TwiML::Response.new do |r|
          r.Message do |message|
            message.Body @greeting + @message
            message.Media @media
          end
        end
        render text: twiml.text
      end
    end
  end



  def help
    # THE HELP FILE - SHOULD BE UPDATED REGULARLY WITH NEW METHODS
    return "Possible commands include: Temperature, Font Gate, Driveway, Light Down, Unlock and more to come..."
  end
end

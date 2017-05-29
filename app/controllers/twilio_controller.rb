class TwilioController < ApplicationController
  require 'twilio-ruby'
  require 'nokogiri'
  require 'open-uri'
  require 'net/http'
  require 'git-version-bump'

  def version
    return "The current version is #{GVB.version} which was launched on #{GVB.date}."
  end

  def outsidelights (state)
    if state == 'on'
      uri = URI("#{ENV['ISY_HOST']}/rest/nodes/41302/cmd/DON")
        Net::HTTP.start(uri.host,uri.port) do |http|
          req = Net::HTTP::Get.new(uri.path)
          req.basic_auth ENV['ISY_USER'], ENV['ISY_PASSWORD']
          response = http.request(req)
        end
      return "I just turned the backyard lights on."
    else
      uri = URI("#{ENV['ISY_HOST']}/rest/nodes/41302/cmd/DOF")
      Net::HTTP.start(uri.host,uri.port) do |http|
        req = Net::HTTP::Get.new(uri.path)
        req.basic_auth ENV['ISY_USER'], ENV['ISY_PASSWORD']
        response = http.request(req)
      end
      return "I just turned the backyard lights off."
    end

  end

  def frontlight (state)
    if state == 'on'
      uri = URI("#{ENV['ISY_HOST']}/rest/nodes/34%206E%202B%202/cmd/DON")
      Net::HTTP.start(uri.host,uri.port) do |http|
        req = Net::HTTP::Get.new(uri.path)
        req.basic_auth ENV['ISY_USER'], ENV['ISY_PASSWORD']
        response = http.request(req)
      end
      return "I just turned the front door light on."
    else
      uri = URI("#{ENV['ISY_HOST']}/rest/nodes/34%206E%202B%202/cmd/DOF")
      Net::HTTP.start(uri.host,uri.port) do |http|
        req = Net::HTTP::Get.new(uri.path)
        req.basic_auth ENV['ISY_USER'], ENV['ISY_PASSWORD']
        response = http.request(req)
      end
      return "I just turned the front door light off."
    end

  end

  def fireplace (state)
    if state == 'on'
      uri = URI("#{ENV['ISY_HOST']}/rest/programs/0018/runThen")
      Net::HTTP.start(uri.host,uri.port) do |http|
        req = Net::HTTP::Get.new(uri.path)
        req.basic_auth ENV['ISY_USER'], ENV['ISY_PASSWORD']
        response = http.request(req)
      end
      return "Break out the marshmallows. Fire is on."
    else
      uri = URI("#{ENV['ISY_HOST']}/rest/programs/0018/runElse")
      Net::HTTP.start(uri.host,uri.port) do |http|
        req = Net::HTTP::Get.new(uri.path)
        req.basic_auth ENV['ISY_USER'], ENV['ISY_PASSWORD']
        response = http.request(req)
      end
      return "The fireplace is off."
    end

  end

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
      log = Log.create(response: 'Denied', phone: params[:From], body: params[:Body])
      twiml = Twilio::TwiML::Response.new do |r|
        r.Message "Oh hey there stranger! You need to be registered in order to text the house."
      end
      render text: twiml.text
    elsif !@user.active
        log = Log.create(response: 'Unauthorized', phone: params[:From], body: params[:Body])
        twiml = Twilio::TwiML::Response.new do |r|
          r.Message "Oh hey there stranger! Your account needs to be active in order to text the house"
        end
        render text: twiml.text
    else
      @guest = @user.guest

      # USER WAS FOUND, LET'S START PARSING
      # START NEW MESSAGE PARSING HERE!!!!
      @in = params[:Body].downcase
      case
        when @in.include?("help")
          log = Log.create(response: 'Help', phone: params[:From], body: params[:Body])
          @message = help
        when @in.include?("version")
          log = Log.create(response: 'Info', phone: params[:From], body: params[:Body])
          @message = version
        when (@in.include?("temp") || @in.include?("temperature") || @in.include?("hot") || @in.include?("cold")) && !@guest
          log = Log.create(response: 'Temperature', phone: params[:From], body: params[:Body])
          @message = temperature
        when ((@in.include?("fireplace") || @in.include?("fire")) && @in.include?("off")) && !@guest
          @message = fireplace 'off'
          log = Log.create(response: 'Fireplace', phone: params[:From], body: params[:Body])
        when ((@in.include?("fireplace") || @in.include?("fire")) && @in.include?("on")) && !@guest
          @message = fireplace 'on'
          log = Log.create(response: 'Lights', phone: params[:From], body: params[:Body])
        when ((@in.include?("front") || @in.include?("door") || @in.include?("gate")) && @in.include?("light") && @in.include?("off")) && !@guest
          @message = frontlight 'off'
          log = Log.create(response: 'Lights', phone: params[:From], body: params[:Body])
        when ((@in.include?("front") || @in.include?("door") || @in.include?("gate")) && @in.include?("light") && @in.include?("on")) && !@guest
          @message = frontlight 'on'
          log = Log.create(response: 'Lights', phone: params[:From], body: params[:Body])
        when (@in.include?("front") || @in.include?("frontdoor") || @in.include?("gate") || @in.include?("doorbell")) && !@guest
          log = Log.create(response: 'Gate Camera', phone: params[:From], body: params[:Body])
          @message = "Here's what the gate camera say..."
          @media = ENV['BASE_URL'] + '/images/gate.jpg'
        when (@in.include?("drive") || @in.include?("driveway") || @in.include?("cars") || @in.include?("street")) && !@guest
          log = Log.create(response: 'Driveway Camera', phone: params[:From], body: params[:Body])
          @message = "Here's what the driveway camera say..."
          @media = ENV['DRIVEWAY_CAMERA_URL']
        when (@in.include?("living") || @in.include?("room") || @in.include?("couch") || @in.include?("kitchen")) && !@guest
          log = Log.create(response: 'Living Room Camera', phone: params[:From], body: params[:Body])
          @message = "Here's what the living room camera say..."
          @media = ENV['LVRM_CAMERA_URL']
        when ((@in.include?("outside") || @in.include?("backyard") || @in.include?("side")) && @in.include?("lights") && @in.include?("off")) && !@guest
          @message = outsidelights 'off'
          log = Log.create(response: 'Lights', phone: params[:From], body: params[:Body])
        when ((@in.include?("outside") || @in.include?("backyard") || @in.include?("side")) && @in.include?("lights") && @in.include?("on")) && !@guest
          @message = outsidelights 'on'
          log = Log.create(response: 'Lights', phone: params[:From], body: params[:Body])
        when (@in.include?("lights") || @in.include?("down")) && !@guest
          log = Log.create(response: 'Lights', phone: params[:From], body: params[:Body])
          @message = lightsdown
        when @in.include?("unlock") || @in.include?("buzz")
          log = Log.create(response: 'Unlock', phone: params[:From], body: params[:Body])
          @message = unlockDoor
        when @in.include?("lock")
          log = Log.create(response: 'Lock', phone: params[:From], body: params[:Body])
          @message = lockDoor
        when (@in.include?("test") || @in.include?("tester")) && !@guest
          log = Log.create(response: 'Test', phone: params[:From], body: params[:Body])
          @message = "This is a test message."
        when @in.include?("panic")
          log = Log.create(response: 'Info', phone: params[:From], body: params[:Body])
          @message = "I'm releasing the dogs!"
        when @in.include?("wifi password")
          log = Log.create(response: 'Info', phone: params[:From], body: params[:Body])
          @message = "The wifi password is: #{ENV['WIFI_PASSWORD']}"
        else
          log = Log.create(response: 'Unauthorized', phone: params[:From], body: params[:Body])
          @message = "I'm not sure I know what you are saying dude."
      end

      #---------------------------ADD THE GREETING TO THE MESSAGE----------------------->
      Time.zone = "Pacific Time (US & Canada)"
      current_time = Time.zone.now.to_i
      midnight = Time.zone.now.beginning_of_day.to_i
      noon = Time.zone.now.middle_of_day.to_i
      five_pm = Time.zone.now.change(:hour => 17 ).to_i
      eight_pm = Time.zone.now.change(:hour => 20 ).to_i

      case
        when midnight.upto(noon).include?(current_time)
          @greeting = Greeting.limit(1).order("RANDOM()").where(time_of_day: ["morning","all"])
        when noon.upto(five_pm).include?(current_time)
          @greeting = Greeting.limit(1).order("RANDOM()").where(time_of_day: ["afternoon","all"])
        when five_pm.upto(eight_pm).include?(current_time)
          @greeting = Greeting.limit(1).order("RANDOM()").where(time_of_day: ["evening","all"])
        when eight_pm.upto(midnight + 1.day).include?(current_time)
          @greeting = Greeting.limit(1).order("RANDOM()").where(time_of_day: ["night","all"])
      end

      final_greeting = @greeting.first.text % @user.fname

#----------------------------------SEND THE MESSAGE-------------------------------->
      if @media.nil?
        twiml = Twilio::TwiML::Response.new do |r|
          r.Message final_greeting + " " + @message
        end
        render text: twiml.text
      else
        twiml = Twilio::TwiML::Response.new do |r|
          r.Message do |message|
            message.Body final_greeting + " " + @message
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

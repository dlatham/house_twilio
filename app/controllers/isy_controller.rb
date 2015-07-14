class IsyController < ApplicationController
  require 'nokogiri'

  def temperature
    # get temperature from all thermostat nodes
    @doc = Nokogiri::XML(File.open("http://10.83.3.10:8331/rest/status"))
    @temp = @doc.xpath('//id:property', 'id' => '14 F7 28 1')
    print @temp
  end
end

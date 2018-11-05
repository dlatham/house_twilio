require 'will_paginate'

class LogsController < ApplicationController
  before_action :authorize

  def index
    @logs = Log.select("logs.*, users.fname").joins("LEFT JOIN users ON logs.phone = users.phone").order("created_at DESC").paginate(:page => params[:page], :per_page => 20)
  end

end

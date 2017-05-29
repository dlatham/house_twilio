require 'will_paginate'

class LogsController < ApplicationController
  before_filter :authorize

  def index
    @logs = Log.order("created_at DESC").paginate(:page => params[:page], :per_page => 20)
  end

end

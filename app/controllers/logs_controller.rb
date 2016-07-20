class LogsController < ApplicationController
  before_filter :authorize

  def index
    @logs = Log.all
  end

end

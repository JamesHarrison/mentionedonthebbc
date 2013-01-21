class ChannelsController < ApplicationController
  def index
    @channels = Channel.includes(:mentions)
  end
end

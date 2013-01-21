class MentionsController < ApplicationController
  def index
    if !params[:q]
      @mentions = Mention.desc(:finish).limit(100)
      @center = {"lng"=>-0.116667, "lat"=>51.5, "title"=>"United Kingdom"}
      fresh_when :last_modified => @mentions.last.finish.utc, :etag => @mentions.last
    else
      @user_coords = Geocoder.search(params[:q]).first
      @mentions = Mention.within_circle(location: [[@user_coords.longitude, @user_coords.latitude], params[:range].to_f])
      @center = {'lat'=>@user_coords.latitude, 'lng'=>@user_coords.longitude, 'title'=>"Your Coordinates"}
    end
    @markers = []
    @mentions.each do |m|
      @markers << {'lat'=>m.location[1], 'lng'=>m.location[0], 'title'=>m.name}
    end
  end

  def show
    @channel = Channel.where(shortname: params[:channel_id]).first
    @mention = Mention.where(slug: params[:id]).first
    @markers = [{'lat'=>@mention.location[1], 'lng'=>@mention.location[0], 'title'=>@mention.name}]
    @center = {'lat'=>@mention.location[1], 'lng'=>@mention.location[0], 'title'=>@mention.name}
    fresh_when :last_modified => @mention.finish.utc, :etag => @mention
  end
end

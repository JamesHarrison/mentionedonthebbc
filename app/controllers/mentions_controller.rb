class MentionsController < ApplicationController
  def index
    if !params[:q]
      @mentions = Mention.desc(:finish)
      @center = {"lng"=>-0.116667, "lat"=>51.5, "title"=>"United Kingdom"}
    else
      @user_coords = Geocoder.search(params[:q]).first
      @mentions = Mention.desc(:finish).within_circle(location: [[@user_coords.longitude, @user_coords.latitude], params[:range].to_f])
      @center = {'lat'=>@user_coords.latitude, 'lng'=>@user_coords.longitude, 'title'=>"Your Coordinates"}
    end
    @start_window = params[:start] ? Time.parse(params[:start]) : Time.now-2.hours
    @finish_window = params[:finish] ? Time.parse(params[:finish]) : Time.now
    @mentions = @mentions.includes(:channel).where(:finish.gt=>@start_window, :finish.lte=>@finish_window)
    @markers = []
    @mentions.each do |m|
      @markers << {'lat'=>m.location[1], 'lng'=>m.location[0], 'title'=>m.name}
    end
    respond_to do |format|
      format.html {}
      format.json {render json: @mentions.to_json}
    end
  end

  def show
    @channel = Channel.where(shortname: params[:channel_id]).first
    @mention = Mention.where(slug: params[:id]).desc(:finish).first
    @markers = [{'lat'=>@mention.location[1], 'lng'=>@mention.location[0], 'title'=>@mention.name}]
    @center = {'lat'=>@mention.location[1], 'lng'=>@mention.location[0], 'title'=>@mention.name}
  end
end

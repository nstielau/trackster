class TracksController < ApplicationController
  before_filter :login_required, :except => :kmz_file

  def kmz_file
    @track = Track.find(params[:id])
    response.headers['Content-Type'] = 'application/vnd.google-earth.kmz'
    response.headers['Content-Disposition'] = "attachment; filename=#{@track.id}.kmz"
    render :text => @track.kmz_file.file.read
  end

  # GET /tracks
  # GET /tracks.xml
  def index
    @tracks = current_user.tracks

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tracks }
    end
  end

  # GET /tracks/1
  # GET /tracks/1.xml
  def show
    @track = Track.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @track }
    end
  end

  # GET /tracks/new
  # GET /tracks/new.xml
  def new
    @track = Track.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @track }
    end
  end

  # POST /tracks
  # POST /tracks.xml
  def create
    @track = Track.create_from_kmz_url(params[:url])
    current_user.tracks << @track

    respond_to do |format|
      if @track.save
        flash[:notice] = 'Track was successfully created.'
        format.html { redirect_to(@track) }
        format.xml  { render :xml => @track, :status => :created, :location => @track }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @track.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tracks/1
  # DELETE /tracks/1.xml
  def destroy
    @track = Track.find(params[:id])
    @track.destroy

    respond_to do |format|
      format.html { redirect_to(tracks_url) }
      format.xml  { head :ok }
    end
  end
end

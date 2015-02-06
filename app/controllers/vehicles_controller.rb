class VehiclesController < ApplicationController
  before_action :set_vehicle, only: [:show, :edit, :update, :destroy, :add_tag, :switch]
  before_action :set_search_params, only: [:index, :search, :reset_search]


  # GET /vehicles
  # GET /vehicles.json
  def index
  end

  # GET /vehicles
  # GET /vehicles.json
  def search
    respond_to do |format| 
      format.html {redirect_to vehicles_path}
    end
  end


  def reset_search
    respond_to do |format| 
      format.html {redirect_to vehicles_path}
    end
  end

  def switch
    respond_to do |format|
      format.js {}
    end
  end



  def show
    @vehicle2 = Vehicle.find(2)
  end

  # GET /vehicles/new
  def new
    @vehicle = Vehicle.new
  end

  # GET /vehicles/1/edit
  def edit
  end

  
  def add_tag
    @vehicle.tag_list.add(params[:vehicle][:tag])
    respond_to do |format|
      if @vehicle.save
        format.html { redirect_to @vehicle, notice: 'Vehicle was successfully updated.' }
        format.json { render :show, status: :ok, location: @vehicle }
      else
        format.html { render :edit }
        format.json { render json: @vehicle.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /vehicles
  # POST /vehicles.json
  def create
    @vehicle = Vehicle.new(vehicle_params)

    respond_to do |format|
      if @vehicle.save
        format.html { redirect_to @vehicle, notice: 'Vehicle was successfully created.' }
        format.json { render :show, status: :created, location: @vehicle }
      else
        format.html { render :new }
        format.json { render json: @vehicle.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vehicles/1
  # PATCH/PUT /vehicles/1.json
  def update
    respond_to do |format|
      if @vehicle.update(vehicle_params)
        format.html { redirect_to @vehicle, notice: 'Vehicle was successfully updated.' }
        format.json { render :show, status: :ok, location: @vehicle }
      else
        format.html { render :edit }
        format.json { render json: @vehicle.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vehicles/1
  # DELETE /vehicles/1.json
  def destroy
    @vehicle.destroy
    respond_to do |format|
      format.html { redirect_to vehicles_url, notice: 'Vehicle was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vehicle
      @vehicle = Vehicle.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vehicle_params
      params.require(:vehicle).permit(:brand, :model, :lowest_price, :highest_price, :image_url, :tag_list)
    end

    def set_search_params
      if params[:tag] and !params[:tag].nil?
        add_search_tag(params[:tag]) if params[:action] == 'index'
        remove_search_tag(params[:tag]) if params[:action] == 'search'
      end

        clear_search_tag if params[:action] == 'reset_search'
  
      if !search_tags.blank?
        @vehicles = Vehicle.tagged_with(search_tags)
      else
        @vehicles = Vehicle.all
      end
    end

end

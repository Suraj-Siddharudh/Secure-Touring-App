class ToursController < ApplicationController
  before_action :set_tour, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /tours
  # GET /tours.json
  def index
    @tours = Tour.all
  end

  # GET /tours/1
  # GET /tours/1.json
  def show
  end

  # GET /tours/new
  def new
    if current_user.is_admin or current_user.is_agent
      @tour = Tour.new
    else
      flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
      redirect_to root_path and return
    end
  end

  # GET /tours/1/edit
  # Edit only the tours added by the agent or Admin himself/herself
  def edit
    tour_owner = Tour.where(id: params[:id]).pluck(:user_id)
    if (tour_owner[0] == current_user.id) or current_user.is_admin
    else
      respond_to do |format|
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        format.html { redirect_to root_path }
      end
    end
  end

  # POST /tours
  # POST /tours.json
  def create
    if current_user.is_admin || current_user.is_agent
      @tour = Tour.new(tour_params)
      @tour.avail_seats = @tour.total_seats
      @tour.user_id = current_user.id
      respond_to do |format|
        if @tour.save
          format.html { redirect_to @tour, notice: 'Tour was successfully created.' }
          format.json { render :show, status: :created, location: @tour }
        else
          logger.error @tour.errors
          format.html { render :new }
          format.json { render json: "We encountered an unprecedented error. Systems will recover soon... You may try again after some time. If the Issue persist, contact Admin", status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        format.html { redirect_to root_path }
      end
    end
  end

  # PATCH/PUT /tours/1
  # PATCH/PUT /tours/1.json
  def update
    tour_owner = Tour.where(id: params[:id]).pluck(:user_id)
    if (tour_owner[0] == current_user.id) or current_user.is_admin
      if params[:tour][:remove_image].present?
        @tour.remove_image!
      end
      respond_to do |format|
        if @tour.update(tour_params)
          format.html { redirect_to @tour, notice: 'Tour was successfully updated.' }
          format.json { render :show, status: :ok, location: @tour }
        else
          format.html { render :edit }
          format.json { render json: "We encountered an unprecedented error. Systems will recover soon... You may try again after some time. If the Issue persist, contact Admin ", status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        format.html { redirect_to root_path }
      end
    end
  end

  # DELETE /tours/1
  # DELETE /tours/1.json
  def destroy
    tour_owner = Tour.where(id: params[:id]).pluck(:user_id)
    if (tour_owner[0] == current_user.id) or current_user.is_admin
      @tour.destroy
      respond_to do |format|
        format.html { redirect_to tours_url, notice: 'Tour was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        format.html { redirect_to root_path }
      end
    end
  end
  INTEGER_MAX = 300000
  PRICE_MAPPING = {
    1 => [0, 1999],
    2 => [2000, 4999],
    3 => [5000, 9999],
    4 => [10000, 14999],
    5 => [15000, INTEGER_MAX]
  }

  # def new_search
  # end

  def search 
    @sp = params.fetch(:search_params, {})
    @tours = Tour.all
    @tours = @tours.where('start_date >= ?', @sp['StartDate']) if @sp['StartDate'].present?
    @tours = @tours.where('end_date >= ?', @sp['EndDate']) if @sp['EndDate'].present?
    @tours = @tours.where('Name LIKE ?', "%#{@sp['Name']}%") if @sp['Name'].present? && @sp['Name'] != ""
    @tours = @tours.where('countries LIKE ?', "%#{@sp['countries']}%") if @sp['countries'].present? && @sp['countries'] != ""
    @tours = @tours.where(:Price => PRICE_MAPPING[@sp['Price'].to_i][0]...PRICE_MAPPING[@sp['Price'].to_i][1]) if @sp['Price'].present?
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tour
      @tour = Tour.find_by(id: params[:id])
      if @tour.nil?
        respond_to do |format|
          flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
          format.html { redirect_to root_path }
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tour_params
      params.require(:tour).permit(:Name, :Description, :Price, :start_date, :end_date, :pickup, :total_seats, :avail_seats, :avail_waitlist, :status, :booking_deadline, :countries, :states, :user_id, :image, :remove_image)
    end
end

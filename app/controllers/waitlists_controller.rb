class WaitlistsController < ApplicationController
  before_action :set_waitlist, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:show, :index]
  # GET /waitlists
  # GET /waitlists.json
  def index
    if current_user.is_admin
      @waitlists = Waitlist.all
    elsif current_user.is_agent
      tour_owner = Tour.where(id: params[:tour_id]).pluck(:user_id)
      if tour_owner[0] == current_user.id
        @waitlists = Waitlist.where(tour_id: params[:tour_id])
      else
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        redirect_to root_path and return
      end
    elsif current_user.is_customer
      @waitlists = Waitlist.where(user_id: current_user.id)
    end
  end

  # GET /waitlists/1
  # GET /waitlists/1.json
  def show
    waitlist_user = Waitlist.where(id: params[:id]).pluck(:user_id)
    waitlist_tour = Waitlist.where(id: params[:id]).pluck(:tour_id)
    tour_agent = Tour.where(id: waitlist_tour[0]).pluck(:user_id)
    if (waitlist_user[0] == current_user.id) or current_user.is_admin or (tour_agent[0] == current_user.id)
    else
      respond_to do |format|
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        format.html { redirect_to root_path }
      end
    end
  end

  # GET /waitlists/new
  def new
    @tour = Tour.find(@tour_id)
    @waitlist = Waitlist.new
  end

  # GET /waitlists/1/edit
  def edit
  end

  # POST /waitlists
  # POST /waitlists.json
  def create
    @waitlist = Waitlist.new(waitlist_params)
    @tour = Tour.find(waitlist_params[:tour_id])

    respond_to do |format|
      if @waitlist.save
        format.html { redirect_to @waitlist, notice: 'Waitlist was successfully created.' }
        format.json { render :show, status: :created, location: @waitlist }
      else
        logger.error @waitlist.errors
        format.html { render :new }
        format.json { render json: "We encountered an unprecedented error. Systems will recover soon... You may try again after some time. If the Issue persist, contact Admin", status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /waitlists/1
  # PATCH/PUT /waitlists/1.json
  def update

    respond_to do |format|
      if @waitlist.update(waitlist_params)
        format.html { redirect_to @waitlist, notice: 'Waitlist was successfully updated.' }
        format.json { render :show, status: :ok, location: @waitlist }
      else
        logger.error @waitlist.errors
        format.html { render :edit }
        format.json { render json: "We encountered an unprecedented error. Systems will recover soon... You may try again after some time. If the Issue persist, contact Admin", status: :unprocessable_entity }
      end
    end
  end

  # DELETE /waitlists/1
  # DELETE /waitlists/1.json
  def destroy
    
    @waitlist.destroy

    respond_to do |format|
      format.html { redirect_to waitlists_url, notice: 'Waitlist was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_waitlist
      @waitlist = Waitlist.find_by(id: params[:id])
      if @waitlist.nil?
        respond_to do |format|
          flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
          format.html { redirect_to root_path }
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def waitlist_params
      params.require(:waitlist).permit(:no_of_seats, :user_id, :tour_id)
    end
end

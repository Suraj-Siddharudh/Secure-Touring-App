class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :edit, :update, :destroy]
  before_action :check_prior_booking, only: [:create]
  before_action :authenticate_user!

  def check_prior_booking
    @prior_booking = Booking.where(:user_id => current_user.id, :tour_id => params[:tour_id])
    unless @prior_booking.blank?
      flash[:notice] = "ERROR: Cannot reserve more than one booking for same tour"
      redirect_to root_path and return
    end
  end

  def waitlist_handler(tour_id)

      @tour = Tour.find(tour_id)
      # puts @tour.Name
      seats_available = @tour.avail_seats
      waitlists = Waitlist.where(tour_id: tour_id)

      waitlists.each do |waitlist|
        if waitlist.no_of_seats <= seats_available
          seats_available = seats_available - waitlist.no_of_seats
          @booking = Booking.new
          @booking.no_of_seats = waitlist.no_of_seats
          @booking.user_id = waitlist.user_id
          @booking.tour_id = waitlist.tour_id
          @booking.save
          @tour.avail_seats = seats_available
          @tour.avail_waitlist = @tour.avail_waitlist - waitlist.no_of_seats
          @tour.save
          begin
            ConfirmationMailer.with(bookmark: waitlist.user_id).new_confirmation_mail.deliver_now
          rescue
            flash[:notice] = "Cannot send the email right now, contact Admin!!"
          end
          waitlist.destroy
        end
    end
  end

  # GET /bookings
  # GET /bookings.json
  # Displays all the Booking for that User
  def index
    # @booking = Booking.where(user_id: current_user.id)
    if current_user.is_admin
      @bookings = Booking.all
    # Display only the booked user for that tour
    elsif current_user.is_agent
      tour_owner = Tour.where(id: params[:tour_id]).pluck(:user_id)
      if tour_owner[0] == current_user.id
        @bookings = Booking.where(tour_id: params[:tour_id])
      else
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        redirect_to root_path and return
      end
    elsif current_user.is_customer
      @bookings = Booking.where(user_id: current_user.id)
    end

  end

  # GET /bookings/1
  # GET /bookings/1.json
  # Displays specific booking for a user and to the agent
  def show
    booking_user = Booking.where(id: params[:id]).pluck(:user_id)
    booked_tour = Booking.where(id: params[:id]).pluck(:tour_id)
    tour_agent = Tour.where(id: booked_tour[0]).pluck(:user_id)
    if (booking_user[0] == current_user.id) or current_user.is_admin or (tour_agent[0] == current_user.id)
    else
      respond_to do |format|
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        format.html { redirect_to root_path }
      end
    end
  end

  # GET /bookings/new
  def new
    if current_user.is_admin || current_user.is_customer
      @tour_id = initial_booking_params["tour_id"]
      @tour = Tour.find(@tour_id)
      @booking = Booking.new
    else
      respond_to do |format|
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        format.html { redirect_to root_path }
      end
    end
  end

  # GET /bookings/1/edit
  def edit
    booking_user = Booking.where(id: params[:id]).pluck(:user_id)
    if (booking_user[0] == current_user.id) or current_user.is_admin
    else
      respond_to do |format|
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        format.html { redirect_to root_path }
      end
    end
  end

  # POST /bookings
  # POST /bookings.json
  # Allow Admin and Customer Only. Check if the user they say in request is actually what they are!!
  def create
    if (current_user.is_admin || current_user.is_customer) && (current_user.id == booking_params[:user_id].to_i)
      booking_params[:user_id] = current_user.id
      @booking = Booking.new(booking_params.except(:option))
      @tour = Tour.find(booking_params[:tour_id])
      @overbooked = false
      ready = false
      # Check if the Tour is Completed already
      if @tour.status.eql? "Completed"
          flash[:notice] = "Cannot book a completed Tour"
          redirect_to root_path and return
      end
      # Check if the Tour is Overbooked
      if @booking.no_of_seats > @tour.avail_seats
        @overbooked = true
      end
      # Check the no of seats booked
      if @booking.no_of_seats < 1 or @booking.no_of_seats > 100
        flash[:notice] = "Allowed to Book 1-100 Seats only"
        redirect_to root_path and return
      end

      respond_to do |format|
        if @overbooked
          if booking_params['option'] == "Book only avaialble seats" and @tour.avail_seats > 0
            @booking.no_of_seats = @tour.avail_seats
            message = "We were able to book " + @booking.no_of_seats.to_s + " seats for you."
            ready = true
          elsif booking_params['option'] == "Book all avaialble seats and waitlist remaining" and @tour.avail_seats > 0
            waitlist_count = @booking.no_of_seats - @tour.avail_seats
            @booking.no_of_seats = @tour.avail_seats
            waitlist = Waitlist.new({"user_id" => current_user.id, "tour_id" => booking_params[:tour_id], "no_of_seats" => waitlist_count}).save
            ready = true
            @tour.avail_waitlist = waitlist_count
            @tour.save
            message = "We were able to book " + @booking.no_of_seats.to_s + " seats for you."
          elsif booking_params['option'] == "Add all seats to Waitlist"
            waitlist_count = @booking.no_of_seats
            @booking.no_of_seats = 0
            waitlist = Waitlist.new({"user_id" => current_user.id, "tour_id" => booking_params[:tour_id], "no_of_seats" => waitlist_count}).save
            ready = true
            @tour.avail_waitlist = waitlist_count
            @tour.save
          elsif booking_params['options'].present?
            flash[:notice] = "Hello Bob!!! trying to change the options.. We don't support it :P "
            redirect_to root_path and return
          else
          end
        end


        if (ready or not @overbooked) and (@booking.no_of_seats >0 and @booking.save)
          @tour.avail_seats = @tour.avail_seats - @booking.no_of_seats
          @tour.save
          format.html { redirect_to @booking, notice: message }
          format.json { render :show, status: :created, location: @booking }
        elsif @booking.no_of_seats == 0 and ready
          flash[:notice] = "Added the seats to waitlist"
          redirect_to root_path and return
        else
          flash[:notice] = "Booking cannot be processed, check for No of Seats"
          format.html { render :new }
          format.json { render json: "Booking Cannot be processed, check for No of Seats", status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        format.html { redirect_to root_path }
      end
    end
  end

  # PATCH/PUT /bookings/1
  # PATCH/PUT /bookings/1.json
  def update
    booking_user = Booking.where(id: params[:id]).pluck(:user_id)
    if (booking_user[0] == current_user.id) or current_user.is_admin
      current_seat_count = @booking.no_of_seats
      requested_seat_count = booking_params[:no_of_seats].to_i

      @tour = Tour.find(@booking.tour_id)
      
      respond_to do |format|
        if requested_seat_count > current_seat_count
          @booking.errors.add(:no_of_seats, "You can only reduce your ticket count. You have " + current_seat_count.to_s + " seats currently. Make another booking if you want to increase the seats.")
          format.html { render :edit }
          format.json { render json: @booking.errors, status: :unprocessable_entity }
        elsif requested_seat_count == 0
          @booking.errors.add(:no_of_seats, "If you want to have 0 seats, please cancel the reservation.")
          format.html { render :edit }
          format.json { render json: @booking.errors, status: :unprocessable_entity }
        elsif @booking.update(booking_params)
              @tour.avail_seats = @tour.avail_seats - requested_seat_count + current_seat_count
              @tour.save
              waitlist_handler(@booking.tour_id)
              format.html { redirect_to @booking, notice: 'Customer booking was successfully updated to ' + requested_seat_count.to_s + " seats."}
              format.json { render :show, status: :ok, location: @booking }
        else
              format.html { render :edit }
              flash[:notice] = "We encountered an unprecedented error. Systems will recover soon... You may try again after some time. If the Issue persist, contact Admin"
        end
      end
    else
      respond_to do |format|
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        format.html { redirect_to root_path }
      end
    end
  end

  # DELETE /bookings/1
  # DELETE /bookings/1.json
  def destroy
    booking_user = Booking.where(id: params[:id]).pluck(:user_id)
    if (booking_user[0] == current_user.id) or current_user.is_admin
      @tour = Tour.find(@booking.tour_id)
      @tour.avail_seats = @tour.avail_seats + @booking.no_of_seats
      @tour.save
      @booking.destroy
      waitlist_handler(@tour.id)
      respond_to do |format|
        format.html { redirect_to bookings_url, notice: 'Booking was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        format.html { redirect_to root_path }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = Booking.find_by(id: params[:id])
      if @booking.nil?
        respond_to do |format|
          flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
          format.html { redirect_to root_path }
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def booking_params
      params.require(:booking).permit(:no_of_seats, :user_id, :tour_id, :option)
    end

    def initial_booking_params
      params.permit(:tour_id)
    end
end

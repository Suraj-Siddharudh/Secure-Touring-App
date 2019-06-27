class ReviewsController < ApplicationController
  before_action :set_review, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:show, :index, :destroy, :create, :new]

  # GET /reviews
  # GET /reviews.json
  def index
    if current_user.is_admin
      @reviews = Review.all
    # elsif current_user.is_agent
    #   # tour_owner = Tour.where(id: params[:tour_id]).pluck(:user_id)
    #   @reviews = Review.all
    #   # @reviews = Review.where(tour_id: params[:tour_id])#.where(user_id: tour_owner)
    elsif current_user.is_customer
      @reviews = Review.where(user_id: current_user.id)
    end
  end

  # GET /reviews/1
  # GET /reviews/1.json
  def show
    review_user = Review.where(id: params[:id]).pluck(:user_id)
    if (review_user[0] == current_user.id) or current_user.is_admin
    else
      respond_to do |format|
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        format.html { redirect_to root_path }
      end
    end
  end

  # GET /reviews/new
  def new
    if current_user.is_admin || current_user.is_customer
      @review = Review.new
    else
      respond_to do |format|
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        format.html { redirect_to root_path }
      end
    end
  end

  # GET /reviews/1/edit
  def edit
  end

  # POST /reviews
  # POST /reviews.json
  def create
    if current_user.is_admin || current_user.is_customer
      review_params[:user_id] = current_user.id
      @review = Review.new(review_params)

      respond_to do |format|
        if @review.save
          format.html { redirect_to @review, notice: 'Review was successfully created.' }
          format.json { render :show, status: :created, location: @review }
        else
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

  # PATCH/PUT /reviews/1
  # PATCH/PUT /reviews/1.json
  def update
    respond_to do |format|
      if @review.update(review_params)
        format.html { redirect_to @review, notice: 'Review was successfully updated.' }
        format.json { render :show, status: :ok, location: @review }
      else
        format.html { render :edit }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
    review_user = Review.where(id: params[:id]).pluck(:user_id)
    if (review_user[0] == current_user.id) or current_user.is_admin
      @review.destroy
      respond_to do |format|
        format.html { redirect_to reviews_url, notice: 'Review was successfully destroyed.' }
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
    def set_review
      @review = Review.find_by(id: params[:id])
      if @review.nil?
        respond_to do |format|
          flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
          format.html { redirect_to root_path }
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def review_params
      params.require(:review).permit(:subject, :content, :user_id, :tour_id, :booking_id)
    end
end

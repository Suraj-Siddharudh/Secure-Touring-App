class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /users
  # GET /users.json
  def index
    if user_signed_in? && !current_user.is_admin
      respond_to do |format|
        format.html { redirect_to root_path }
      end
      return
    end
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  # def show
  #   if (params[:id] != current_user.id) or !current_user.is_admin
  #     respond_to do |format|
  #       format.html { redirect_to root_path }
  #     end
  #   end
  #   @user = User.find(params[:id])
  # end
  
  # GET /users/new
  def new
    if user_signed_in? && !current_user.is_admin
      respond_to do |format|
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        format.html { redirect_to root_path }
      end
      return
    end
    @user = User.new
  end

  # GET /user/1/edit
  def edit
    # Allow users to edit their profile unless they are Admin
    if (params[:id].to_i == current_user.id) or current_user.is_admin
      if @user.role.eql? "Customer"
        @user.is_customer = 1
        @user.is_agent = 0
      else
        @user.is_customer = 0
        @user.is_agent = 1
      end
    else
      respond_to do |format|
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        format.html { redirect_to root_path }
      end
    end
    
  end

  # POST /users
  # POST /users.json
  def create
    if user_signed_in? && !current_user.is_admin
      respond_to do |format|
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        format.html { redirect_to root_path }
      end
      return
    end
    @user = User.new(user_params)
    if @user.role.eql?"Customer"
      @user.is_customer = 1
      @user.is_agent = 0
    else
      @user.is_customer = 0
      @user.is_agent = 1
    end

    respond_to do |format|
      if @user.save
        format.html { redirect_to root_path, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        logger.error @user.errors.full_messages.to_sentence
        format.html { render :new }
        format.json { render json: "We encountered an unprecedented error. Systems will recover soon... You may try again after some time. If the Issue persist, contact Admin", status: :unprocessable_entity }
      end
    end
  end

  def customer
    if user_signed_in? && !current_user.is_admin
      respond_to do |format|
        format.html { redirect_to root_path }
      end
      return
    end
    @users= User.where(is_customer: 1)
  end

  def agent 
    if user_signed_in? && !current_user.is_admin
      respond_to do |format|
        format.html { redirect_to root_path }
      end
      return
    end
    @users= User.where(is_agent: 1)
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  # def update
    
  #   respond_to do |format|
  #     if @user.update(user_params)
  #       format.html { redirect_to @user, notice: 'User was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @user }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @user.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    if @user.is_admin
      redirect_to root_path, notice: "Admin accounts cannot be deleted." and return
    end
    if (params[:id].to_i == current_user.id) or current_user.is_admin
      @user.destroy
      respond_to do |format|
        format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        format.html { redirect_to root_path }
      end
    end
  end

  def update
    if (params[:id].to_i == current_user.id) or current_user.is_admin
      if "Customer".eql? params[:user][:role]
        @user.is_customer = 1
        @user.is_agent = 0
      else
        @user.is_customer = 0
        @user.is_agent = 1
      end
      respond_to do |format|
        if @user.update_without_password(user_params)
          format.html { redirect_to root_path, notice: 'User was successfully updated.' }
          format.json { render :show, status: :ok, location: @user }
        else
          logger.error "We encountered an unprecedented error. Systems will recover soon... You may try again after some time. If the Issue persist, contact Admin"
          format.html { render :edit }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find_by(id: params[:id])
      if @user.nil?
        respond_to do |format|
          flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
          format.html { redirect_to root_path }
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.fetch(:user, {})
      params.require(:user).permit(:first_name, :last_name, :role, :email, :is_customer, :phone_number, :is_agent, :password, :password_confirmation)
    end
end

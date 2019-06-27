class BookmarksController < ApplicationController
  before_action :set_bookmark, only: [:show, :edit, :update, :destroy]

  # GET /bookmarks
  # GET /bookmarks.json
  def index
    if current_user.is_admin
      @bookmarks = Bookmark.all
    elsif current_user.is_agent
      tour_owner = Tour.where(id: params[:tour_id]).pluck(:user_id)
      if tour_owner[0] == current_user.id
        @bookmarks = Bookmark.where(tour_id: params[:tour_id])
      else
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        redirect_to root_path and return
      end
    elsif current_user.is_customer
      @bookmarks = Bookmark.where(user_id: current_user.id)
    end
  end

  # GET /bookmarks/1
  # GET /bookmarks/1.json
  def show
    bookmark_user = Bookmark.where(id: params[:id]).pluck(:user_id)
    bookmark_tour = Bookmark.where(id: params[:id]).pluck(:tour_id)
    tour_agent = Tour.where(id: bookmark_tour[0]).pluck(:user_id)
    if (bookmark_user[0] == current_user.id) or current_user.is_admin or (tour_agent[0] == current_user.id)
    else
      respond_to do |format|
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        format.html { redirect_to root_path }
      end
    end
  end

  # GET /bookmarks/new
  # def new
  #   if current_user.is_admin || current_user.is_customer
  #     @bookmark = Bookmark.new
  #   else
  #     respond_to do |format|
  #       flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
  #       format.html { redirect_to root_path }
  #     end
  #   end
  # end

  # GET /bookmarks/1/edit
  def edit
    bookmark_user = Bookmark.where(id: params[:id]).pluck(:user_id)
    if (bookmark_user[0] == current_user.id) or current_user.is_admin
    else
      respond_to do |format|
        flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
        format.html { redirect_to root_path }
      end
    end
  end

  # POST /bookmarks
  # POST /bookmarks.json
  def create
    if current_user.is_admin || current_user.is_customer
      # Check if the user has already bookmarked the tour
      bookmark_user = Bookmark.where(tour_id: params[:tour_id]).pluck(:user_id)
      if bookmark_user[0] == current_user.id
        flash[:notice] = "Cannot Bookmark the same tour twice!!"
        redirect_to root_path and return
      end
      @bookmark = Bookmark.new({
        user_id: current_user.id,
        tour_id: params[:tour_id]
      })

      respond_to do |format|
        if @bookmark.save
          format.html { redirect_to @bookmark, notice: 'Bookmark was successfully created.' }
          format.json { render :show, status: :created, location: @bookmark }
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

  # PATCH/PUT /bookmarks/1
  # PATCH/PUT /bookmarks/1.json
  def update
    bookmark_user = Bookmark.where(id: params[:id]).pluck(:user_id)
    if bookmark_user[0] == current_user.id
      respond_to do |format|
        if @bookmark.update(bookmark_params)
          format.html { redirect_to @bookmark, notice: 'Bookmark was successfully updated.' }
          format.json { render :show, status: :ok, location: @bookmark }
        else
          logger.error @bookmark.errors
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

  # DELETE /bookmarks/1
  # DELETE /bookmarks/1.json
  def destroy
    bookmark_user = Bookmark.where(id: params[:id]).pluck(:user_id)
    if (bookmark_user[0] == current_user.id) or current_user.is_admin
      @bookmark.destroy
      respond_to do |format|
        format.html { redirect_to bookmarks_url, notice: 'Bookmark was successfully destroyed.' }
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
    def set_bookmark
      @bookmark = Bookmark.find_by(id: params[:id])
      if @bookmark.nil?
        respond_to do |format|
          flash[:notice] = "Hello Bob!! trying to bypass access controls.. You ain't Gonna Succeed :P "
          format.html { redirect_to root_path }
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bookmark_params
      params.require(:bookmark).permit(:user_id, :created_at, :updated_at, :tour_id)
    end
end

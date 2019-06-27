class ErrorsController < ApplicationController
    protect_from_forgery with: :null_session
    def error_404
      render 'errors/not_found'
    # raise ActionController::RoutingError.new(params[:path])
    end
  end
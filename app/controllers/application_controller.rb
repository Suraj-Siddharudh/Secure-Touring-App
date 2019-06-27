class ApplicationController < ActionController::Base
	protect_from_forgery # with: :exception
	before_action :authenticate_user!

	rescue_from ActionController::RoutingError, with: -> { render_404  }
	rescue_from ActiveRecord::RecordNotFound,        with: -> { render_404  }

	
	  def render_404
		respond_to do |format|
		  format.html { render template: 'errors/not_found', status: 404 }
		  format.all { render nothing: true, status: 404 }
		end
	  end
end

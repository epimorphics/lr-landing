class LandingController < ApplicationController
  def index
    template = "landing/index"
    template = "#{template}-#{params[:lang]}" if params[:lang]

    render template: template
  end
end

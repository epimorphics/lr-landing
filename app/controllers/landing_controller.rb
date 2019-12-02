# frozen_string_literal: true

# Controller for main landing page.
# Corresponds to `/` and `/landing` routes
class LandingController < ApplicationController
  def index
    template = 'landing/index'
    template = "#{template}-#{params[:lang]}" if params[:lang]

    render template: template
  end
end

# frozen_string_literal: true

class Api::BaseController < ActionController::API
  include ActionController::MimeResponds
  include ApiSessionHelper
  include JwtAuthentication
end

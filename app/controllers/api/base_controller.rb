# frozen_string_literal: true

class Api::BaseController < ActionController::API
  include ActionController::MimeResponds
  include ApiSessionHelper
  include JwtAuthentication

  def is_xml?
    request.content_type == "application/xml" || request.format.xml?
  end
end

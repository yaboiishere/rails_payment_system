# frozen_string_literal: true

class Api::BaseController < ActionController::API
  include ActionController::MimeResponds
  include ApiSessionHelper
  include JwtAuthentication

  def is_xml?
    request.content_type == "application/xml" || request.format.xml?
  end

  def render_response(success:, data: nil, errors: nil, ok_status: :ok, error_status: :unprocessable_entity)
    if success
      if is_xml?
        render xml: data, status: ok_status
      else
        render json: data, status: ok_status
      end
    else
      if is_xml?
        render xml: errors, status: error_status
      else
        render json: errors, status: error_status
      end
    end
  end
end

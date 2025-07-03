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

  def check_idempotency
    key = request.headers["Idempotency-Key"]
    return render_response(success: false, errors: { error: "Idempotency key header is required for this endpoint" }, error_status: :bad_request) unless key

    idempotency = Idempotency.new(user: current_user, key: key, request_body: request.raw_post)

    if idempotency.cached?
      cached = idempotency.read
      render_response(success: true, data: cached[:body], ok_status: cached[:status])
    else
      result = yield
      idempotency.store(response: result[:response], status: result.success? ? :created : :unprocessable_entity) if result.success?

      render_response(
        success: result.success?,
        data: result[:response],
        errors: { errors: result[:errors] },
        ok_status: :created,
        error_status: :unprocessable_entity)
    end
  end
end

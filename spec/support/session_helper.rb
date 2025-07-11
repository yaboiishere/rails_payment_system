# frozen_string_literal: true

module SessionHelper
  include ActionDispatch::Cookies::ChainedCookieJars
  include ApiSessionHelper

  def sign_in_as(user)
    Current.session = user.sessions.create!

    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[:session_id] = Current.session.id
      cookies[:session_id] = cookie_jar[:session_id]
    end
  end

  def create_jwt_token(user)
    jwt_encode(user.id)
  end

  def to_xml(data, root)
    data.to_xml(root: root, dasherize: false, skip_types: true)
  end
end

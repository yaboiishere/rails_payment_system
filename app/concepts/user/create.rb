# frozen_string_literal: true

class User::Create < Trailblazer::Operation
  step :determine_user_type
  step :create_user

  def determine_user_type(ctx, params:, **)
    user_type = params[:type]
    ctx[:errors] ||= []
    if user_type.nil? || user_type.empty?
      ctx[:errors] << "Missing type parameter. Valid types are: merchant, admin"
      return false
    end
    user_type = user_type.to_s.downcase
    case user_type
    when "merchant"
      ctx[:params][:type] = User::Merchant
    when "admin"
      ctx[:params][:type] = User::Admin
    else
      ctx[:errors] << "Invalid user type: #{user_type}. Valid types are: merchant, admin"
      return false
    end

    true
  end

  def create_user(ctx, params:, **)
    user = User.new(params)
    if user.save
      ctx[:model] = user
      true
    else
      ctx[:errors] ||= []
      ctx[:errors].concat(user.errors.full_messages)
      false
    end
  end
end

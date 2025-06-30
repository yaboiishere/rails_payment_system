class HomeController < ApplicationController
  def index
    case Current.user
    when User::Merchant
      redirect_to merchant_path(Current.user)
    when User::Admin
      redirect_to merchant_index_path
    else
      redirect_to new_session_path
    end
  end
end

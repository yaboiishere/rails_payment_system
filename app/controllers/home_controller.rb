class HomeController < ApplicationController
  def index
    if Current.user.admin?
      redirect_to merchant_index_path
    else
      redirect_to merchant_path(Current.user)
    end
  end
end

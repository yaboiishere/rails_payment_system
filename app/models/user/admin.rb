# frozen_string_literal: true

class User
  class Admin < User
    def admin?
      true
    end
  end
end

class Api::V1::BaseApiController < ApplicationController

  def current_user
    @user = User.first
  end

end

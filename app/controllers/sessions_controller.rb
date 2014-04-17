class SessionsController < ApplicationController
  def create
    #What data comes back from OmniAuth?
    @auth = request.env["omniauth.auth"]

    # See if we have a user with this email
    @user = User.find_by_email(@auth["info"]["email"])

    if @user
      @user.refresh_token = @auth["credentials"]["refresh_token"]
      @user.save
    else
      @user = User.create(email: @auth["info"]["email"], oauth_token: @auth["credentials"]["token"], refresh_token: @auth["credentials"]["refresh_token"])
    end

    # Store the user in the session
    session[:user_id] = @user.id

    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil

    redirect_to root_url, :notice => "Signed out!"
  end
end

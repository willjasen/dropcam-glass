class TimelineController < ApplicationController
  def index
  end
  
  def send_message
  credentials = User.get_credentials(session[:user_id])

  data = {
   :client_id => ENV["GLASS_CLIENT_ID"],
   :client_secret => ENV["GLASS_CLIENT_SECRET"],
   :refresh_token => credentials[:refresh_token],
   :grant_type => "refresh_token"
  }

  @response = ActiveSupport::JSON.decode(RestClient.post "https://accounts.google.com/o/oauth2/token", data)
  if @response["access_token"].present?
    credentials[:access_token] = @response["access_token"]

    @client = Google::APIClient.new
    hash = { :access_token => credentials[:access_token], :refresh_token => credentials[:refresh_token] }
    authorization = Signet::OAuth2::Client.new(hash)
    @client.authorization = authorization

    @mirror = @client.discovered_api('mirror', 'v1')

    insert_timeline_item( {
      text: 'Google Glass is awesome!',
      speakableText: "Glass can even read to me. Sweet!",
      notification: { level: 'DEFAULT' },
      menuItems: [
        { action: 'READ_ALOUD' },
        { action: 'DELETE' } ]
      })

    if (@result)
      redirect_to(root_path, :notice => "All Timelines inserted")
    else
      redirect_to(root_path, :alert => "Timelines failed to insert. Please try again.")
    end
  else
    Rails.logger.debug "No access token"
  end
end

def send_dropcam_picture

  require 'dropcam'

dropcam = Dropcam::Dropcam.new(ENV["DROPCAM_USERNAME"],ENV["DROPCAM_PASSWORD"])
camera = dropcam.cameras.second

# returns jpg image data of the latest frame captured
screenshot = camera.screenshot.current

# write data to disk
File.open("#{camera.title}.jpg", 'wb') {|f| f.write(screenshot) }

# access and modify settings
# this disables the watermark on your camera stream
settings = camera.settings
settings["watermark.enabled"].set(false)

  credentials = User.get_credentials(session[:user_id])

  data = {
   :client_id => ENV["GLASS_CLIENT_ID"],
   :client_secret => ENV["GLASS_CLIENT_SECRET"],
   :refresh_token => credentials[:refresh_token],
   :grant_type => "refresh_token"
  }

  @response = ActiveSupport::JSON.decode(RestClient.post "https://accounts.google.com/o/oauth2/token", data)
  if @response["access_token"].present?
    credentials[:access_token] = @response["access_token"]

    @client = Google::APIClient.new
    hash = { :access_token => credentials[:access_token], :refresh_token => credentials[:refresh_token] }
    authorization = Signet::OAuth2::Client.new(hash)
    @client.authorization = authorization

    @mirror = @client.discovered_api('mirror', 'v1')

    insert_timeline_item( {
      text: camera.title + ' Dropcam',
      notification: { level: 'DEFAULT' },
      menuItems: [
        { action: 'DELETE' },
	{ action: 'TOGGLE_PINNED' } ]
      },
      "#{camera.title}.jpg",
      "image/jpeg")

    if (@result)
      redirect_to(root_path, :notice => "All Timelines inserted")
    else
      redirect_to(root_path, :alert => "Timelines failed to insert. Please try again.")
    end

    if File.exist?("#{camera.title}.jpg")
      File.delete("#{camera.title}.jpg")
    end
    
  else
    Rails.logger.debug "No access token"
  end
end

def insert_timeline_item(timeline_item, attachment_path = nil, content_type = nil)
 method = @mirror.timeline.insert

# If a Hash was passed in, create an actual timeline item from it.
 if timeline_item.kind_of?(Hash)
 timeline_item = method.request_schema.new(timeline_item)
 end

if attachment_path && content_type
 media = Google::APIClient::UploadIO.new(attachment_path, content_type)
 parameters = { 'uploadType' => 'multipart' }
 else
 media = nil
 parameters = nil
 end

@result = @client.execute!(
 api_method: method,
 body_object: timeline_item,
 media: media,
 parameters: parameters
 ).data
 end

end

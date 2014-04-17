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

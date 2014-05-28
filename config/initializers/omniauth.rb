Rails.application.config.middleware.use OmniAuth::Builder do
provider :google_oauth2, ENV["GLASS_CLIENT_ID"], ENV["GLASS_CLIENT_SECRET"], {
 access_type: 'offline',
 prompt: 'consent',
 scope: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/glass.timeline',
 redirect_uri:'https://willjasen-dg.ngrok.com/auth/google_oauth2/callback'
 }
end

ENV['RAILS_ENV'] = 'production'

require ::File.expand_path('../config/environment',  __FILE__)
app = Rails.application

request = Rack::Request.new(Rack::MockRequest.env_for("http://noshare.dev/app"))
response = app.call(request.env)
body = response.last.first
puts body

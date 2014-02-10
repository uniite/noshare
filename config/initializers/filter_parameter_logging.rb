# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
# Data_URI isn't especially sensitive, but it is too big to log
Rails.application.config.filter_parameters += [:data_uri, :password]

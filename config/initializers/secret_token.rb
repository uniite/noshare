# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
Noshare::Application.config.secret_key_base = if Rails.env.production?
                                                ENV['SECRET_KEY_BASE']
                                              else
                                                'f0fdd0221762867d3be9afe1c3889356eebb3a430c0508b038b567f46a4604b769c99e57804b75254a79738474669b07ee4b8ffd691c5feecbf50ac313af2cc0'
                                              end

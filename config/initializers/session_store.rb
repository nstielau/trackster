# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_motionx_diary_session',
  :secret      => 'd324f8a845276b7860e0b73fe9fffa4b05273fb90b0508a764ce6f3c01574cde28d7abb1b448aff6096d7006067dbdada58b510f396081123bdde35c71e0ae58'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

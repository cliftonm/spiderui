# Be sure to restart your server when you modify this file.

DatabaseSpider::Application.config.session_store :cookie_store, key: '_DatabaseSpider_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
DatabaseSpider::Application.config.session_store :active_record_store

# override the database that is being used for storing session information
# we don't / can't use the database we're connecting for the spider UI because we don't
# want to be adding tables specifically for the RoR environment.
ActiveRecord::SessionStore::Session.establish_connection(:sessions)

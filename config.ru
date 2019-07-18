require 'fileutils'
require 'logger'
require 'sequel'
# require 'pg' # for postgres
require 'pact_broker'

ENV['RACK_ENV'] ||= 'production'

# Create a real database, and set the credentials for it here
# It is highly recommended to set the encoding to utf8
# DATABASE_CREDENTIALS = {adapter: "sqlite", database: "pact_broker_database.sqlite3", :encoding => 'utf8'}

# For postgres:
#
# $ psql postgres -c "CREATE DATABASE pact_broker;"
# $ psql postgres -c "CREATE ROLE pact_broker WITH LOGIN PASSWORD 'CHANGE_ME';"
# $ psql postgres -c "GRANT ALL PRIVILEGES ON DATABASE pact_broker TO pact_broker;"
#
DATABASE_CREDENTIALS = {adapter: "postgres", database: "da58dl8ic1jaci", username: 'bwvhufshhnfywe', password: 'f6a56c5f2d098912d1292a4d3871e11a7f4e890579a65c459ba6c149bcab11f5', :encoding => 'utf8'}

# Have a look at the Sequel documentation to make decisions about things like connection pooling
# and connection validation.

ENV['TZ'] = 'Australia/Melbourne' # Set the timezone you want your dates to appear in

app = PactBroker::App.new do | config |
  # change these from their default values if desired
  # config.log_dir = "./log"
  # config.auto_migrate_db = true
  config.database_connection = Sequel.connect(DATABASE_CREDENTIALS.merge(:logger => PactBroker::DB::LogQuietener.new(config.logger)))
end

run app

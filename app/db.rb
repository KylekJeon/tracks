require_relative './models/lib/db_connection'

DBConnection.set_db_file('kittens.db')
DBConnection.reset('kittens.sql') unless DBConnection.db_file_exists?

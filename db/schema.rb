require 'sequel'
DB = Sequel.connect('sqlite://db/zakupki.sqlite3')

DB.create_table :regions do
  primary_key :id
  String :name
end

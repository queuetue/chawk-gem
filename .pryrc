$:.unshift('lib')

require 'active_record'
require 'hirb'
require 'chawk'
require 'pp'


ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
ActiveRecord::Migration.verbose = false
require "chawk/migration"
CreateChawkBase.migrate :up
File.open('./test/schema.rb', "w") do |file|
	ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
end

agent =  Chawk::Models::Agent.first || Chawk::Models::Agent.create(:name=>"Test User")
node1 = Chawk.node(agent,'a:b')
node1.points.destroy_all

ts = Time.now.to_f


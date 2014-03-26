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
addr1 = Chawk.addr(agent,'a:b')
addr1.points.destroy_all

ts = Time.now.to_f

# addr1.add_points [
# {'v'=>92, 't'=> 1085.2340175364745},
# {'v'=>94, 't'=> 1100.0643872093362},
# {'v'=>95, 't'=> 1102.3558603493182},
# {'v'=>91, 't'=> 1119.2568446818536},
# {'v'=>85, 't'=> 1125.283357089852},
# {'v'=>98, 't'=> 1131.97881037},
# {'v'=>90, 't'=> 1132.2220135}
# ]


# addr1._insert_point(92,1085.2340175364745)
# addr1._insert_point(94,1100.0643872093362)
# addr1._insert_point(92,1102.3558603493182)
# addr1._insert_point(94,1119.2568446818536)
# addr1._insert_point(91,1125.283357089852)
# addr1._insert_point(91,1131.9783343810343)
# addr1._insert_point(88,1132.299788479544)

#range = Chawk::Models::Range.create(start_ts:1080.0,stop_ts:1140.0,beats:5,parent_node:addr1)

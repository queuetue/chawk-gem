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
addr2 = Chawk.addr(agent,'a:c')
addr3 = Chawk.addr(agent,'a:d')
addr1.points.destroy_all
addr2.points.destroy_all
addr3.points.destroy_all

# x = 1052.35
# v = 100

# 20.times do
#   puts "addr3._insert_point(#{v},#{x})"
#   x += rand*20
#   v += (rand*10).to_i-5
# end

addr1._insert_point(100,1055.35)
addr1._insert_point(99,1061.8881585264594)
addr1._insert_point(96,1068.4745538435902)
addr1._insert_point(92,1085.2340175364745)
addr1._insert_point(94,1100.0643872093362)
addr1._insert_point(92,1102.3558603493182)
addr1._insert_point(94,1119.2568446818536)
addr1._insert_point(91,1125.283357089852)
addr1._insert_point(91,1131.9783343810343)
addr1._insert_point(88,1132.299788479544)
addr1._insert_point(84,1143.8162977468637)
addr1._insert_point(87,1161.0094610592937)
addr1._insert_point(85,1168.1573956303073)
addr1._insert_point(82,1170.3581167678517)
addr1._insert_point(86,1186.0922753164493)
addr1._insert_point(82,1186.6735474993775)
addr1._insert_point(83,1196.6712654484254)
addr1._insert_point(80,1205.2043687599607)
addr1._insert_point(79,1219.8416353799464)
addr1._insert_point(82,1220.3434974040242)

addr2._insert_point(100,1052.35)
addr2._insert_point(96,1063.692588425798)
addr2._insert_point(95,1076.807646424628)
addr2._insert_point(93,1093.6974808234377)
addr2._insert_point(92,1097.2411412783788)
addr2._insert_point(87,1105.2132395159897)
addr2._insert_point(87,1124.8179760753346)
addr2._insert_point(85,1129.7277263712253)
addr2._insert_point(83,1132.3545932644981)
addr2._insert_point(78,1152.0589070864482)
addr2._insert_point(78,1171.7735697428868)
addr2._insert_point(75,1185.870709521205)
addr2._insert_point(76,1187.8692293376)
addr2._insert_point(72,1190.1102767740324)
addr2._insert_point(76,1200.3800358408346)
addr2._insert_point(74,1206.082758690099)
addr2._insert_point(70,1208.124026174909)
addr2._insert_point(67,1227.027568552176)
addr2._insert_point(65,1238.495393270911)
addr2._insert_point(67,1252.917645378507)

addr3._insert_point(100,1052.35)
addr3._insert_point(101,1059.816031809872)
addr3._insert_point(97,1060.1988193518387)
addr3._insert_point(100,1069.5434773761922)
addr3._insert_point(97,1085.2271577820327)
addr3._insert_point(96,1085.890118672737)
addr3._insert_point(95,1092.4640639660179)
addr3._insert_point(95,1106.1278315096156)
addr3._insert_point(92,1122.5981895020082)
addr3._insert_point(89,1123.1438655965337)
addr3._insert_point(92,1135.092423985953)
addr3._insert_point(90,1153.001200779355)
addr3._insert_point(89,1153.1138846058186)
addr3._insert_point(92,1157.9273142052805)
addr3._insert_point(87,1173.2014656912513)
addr3._insert_point(89,1177.3579552635294)
addr3._insert_point(84,1185.8264155964935)
addr3._insert_point(82,1200.906825125549)
addr3._insert_point(85,1206.5932890543006)
addr3._insert_point(87,1226.2913575457123)

range = Chawk::Models::Range.new([addr1,addr2,addr3], 1100,1128,4)

pp range.data
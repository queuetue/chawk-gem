require 'sqlite3'
require "point_sqlite3"
module Chawk
	class SqliteChawkboard
		DB_PROTOCOL_VERSION = "0.0.1"
		attr_reader :db, :root_node
		def initialize(filename,options={})
			@db = SQLite3::Database.new(filename)
			ver = get_db_version
			if !ver
				self.create_db_version
			elsif ver != DB_PROTOCOL_VERSION
				unless self.usable_db_version?
					if options[:IGNORE_DB_PROTOCOL]
						puts "DATABASE PROTOCOL MISMATCH db: #{ver} / me: #{DB_PROTOCOL_VERSION}"
					else
						raise "BAD_DB_PROTOCOL"
					end
				end
			end
			@root_node = get_root_node_id
		end

		def get_root_node_id
			sql = %q{SELECT id FROM nodes WHERE name='ROOT' and parent_id IS NULL;}
			rows = db.execute(sql)
			return rows[0][0];
		end

		def get_pointer(path)
			SqlitePointer.new(self, path)
		end

		def get_db_version
			sql = %q{SELECT count(name) FROM sqlite_master WHERE type='table' AND name='db_version';}
			rows = db.execute(sql)
			if rows[0][0] == 0
				return nil
			else
				rows = db.execute(%q{SELECT version FROM db_version;})
				return rows[0][0]
			end
		end

		def set_db_version(version)
			db.execute("UPDATE db_version set version='#{version}';")
		end

		def create_db_version
			sql = "create table db_version (version varchar2(100)); insert into db_version values('#{DB_PROTOCOL_VERSION}');"
			db.execute_batch(sql)
			sql = "create table nodes (id INTEGER PRIMARY KEY, name TEXT, parent_id INTEGER); insert into nodes values (NULL, 'ROOT', NULL);"
			db.execute_batch(sql)
			sql = "create table value (id INTEGER PRIMARY KEY, value INTEGER, node_id INTEGER, recorded_at DATETIME);"
			db.execute_batch(sql)
			sql = "create table notification_queue (address INTEGER, node_id INTEGER, notified_at DATETIME);"
			db.execute_batch(sql)
		end

		def usable_db_version?
			rows = db.execute("SELECT version FROM db_version;")
			return(rows[0][0] == DB_PROTOCOL_VERSION)
		end

	  def pop_from_notification_queue()
	  	sql = %Q{SELECT OID,address,node_id FROM notification_queue ORDER by OID ASC LIMIT 1;}
		rows = db.execute(sql)
		db.execute(%Q{DELETE FROM notification_queue WHERE oid = #{rows[0][0]};}) unless rows.empty?
		(oid,address,node_id) = rows[0]
	  end

	  def add_to_notification_queue(node_id,address)
	  	sql = %Q{INSERT INTO notification_queue values ('#{address}','#{node_id}','#{Time.now.to_f}');}
		db.execute(sql)
	  end

	  def flush_notification_queue
	  	sql = %Q{DELETE FROM notification_queue;}
		db.execute(sql)
	  end

	  def notification_queue_length
	  	sql = %Q{SELECT count(address) FROM notification_queue;}
		rows = db.execute(sql)
		rows[0][0]	  	
	  end

	end

	class SqlitePointer 
	  attr_accessor :path,:node_id

	  def inspect
	  	"#SqlitePointer '#{self.address}' (#{@node_id})#"
	  end

	  def version
	  	"#{Chawk::VERSION}/1017"
	  end

	  def initialize(board,path)
	  	@board = board
		unless path.is_a?(Array)
			raise ArgumentError
			self.delete
		end

		unless path.reject{|x|x.is_a?(String)}.empty?
			raise ArgumentError
			self.delete
		end

	unless path.select{|x|x.include?('/')}.empty?
			raise ArgumentError
			self.delete
		end

	    @path = path
	    @node_id = find_or_make_db_path(path, @board.root_node)
	  end

	  def find_or_make_db_path(args,current_id)

	  	#TODO NEEDS SANITIZATION

	  	ary = Array.new(args)
	  	name = ary.shift
	  	sql = "SELECT id from nodes where parent_id='#{current_id}' and name='#{name}'"
	  	rows = @board.db.execute(sql)
	  	if rows.empty?
	  		sql = "INSERT INTO nodes values (NULL,'#{name}',#{current_id});"
	  		@board.db.execute(sql)
	  		id = @board.db.last_insert_row_id
	  	else
	  		id = rows[0][0]	  		
	  	end
	  	if ary.length > 0
		  	find_or_make_db_path(ary, id)
		else
			@node_id = id
		end
	  end

	  def address
	    @path.join("/")
	  end

	  def +(other = 1)
	  	raise ArgumentError unless other.integer?
	  	int = (self.last.value.to_i + other.to_i)
	  	self << int
	  end  

	  def -(other = 1)
	  	raise ArgumentError unless other.integer?
	  	int = (self.last.value.to_i - other.to_i)
	  	self << int
	  end  

	  def <<(args)
	  	if args.is_a?(Array)
	  		args.each do |arg|
	  			if arg.is_a?(Integer)
	  				dt = Time.now;
	  				sql = "insert into value values (NULL,#{arg},#{@node_id},'#{dt.to_f }') "
			  		@board.db.execute(sql)
			  		@board.add_to_notification_queue(@node_id,self.address)
	  			else
	  				raise ArgumentError
	  			end
	  		end
	  	else
			if args.is_a?(Integer)
				dt = Time.now;
  				sql = "insert into value values (NULL, #{args},#{@node_id},'#{dt.to_f }') "
		  		@board.db.execute(sql)
			  	@board.add_to_notification_queue(@node_id,self.address)
			else
  				raise ArgumentError
  			end
	  	end
	  	self.last
	  end

	  def last
	  	sql = "SELECT id, value, recorded_at from value where node_id = #{@node_id} ORDER BY recorded_at DESC, id DESC LIMIT 1;"
	  	rows = @board.db.execute(sql)
	  	return nil if rows.empty?
	  	SqlitePoint.new(self, rows[0][1], rows[0][2])
	  end

	  def clear_history!
	  	sql = "DELETE FROM value where node_id = #{@node_id};"
		@board.db.execute(sql)
		@board.add_to_notification_queue(@node_id,self.address)
	  end

	  def length
	  	sql = "SELECT COUNT(value) from value where node_id = #{@node_id};"
		rows = @board.db.execute(sql)
		rows[0][0]
	  end

	  def max
	  	sql = "SELECT id, value,recorded_at from value where node_id = #{@node_id} ORDER BY value DESC LIMIT 1;"
		rows = @board.db.execute(sql)
		rows[0][0]
	  	SqlitePoint.new(self, rows[0][1], rows[0][2])
	  end

	  def min
	  	sql = "SELECT id, value,recorded_at from value where node_id = #{@node_id} ORDER BY value ASC LIMIT 1;"
		rows = @board.db.execute(sql)
		rows[0][0]
	  	SqlitePoint.new(self, rows[0][1], rows[0][2])
	  end

	  def range(dt_from, dt_to)
	  	sql = %Q{
SELECT value, recorded_at from value where node_id = #{@node_id} and 
	recorded_at >= #{dt_from.to_f} and
	recorded_at <= #{dt_to.to_f}
  	ORDER BY recorded_at ASC, id ASC;}
  	#puts sql
	  	rows = @board.db.execute(sql)
	  	#puts "#{rows}"
	  	rows.map do |row|
			#puts "#{row}"
	  		SqlitePoint.new(self, row[0], row[1])
	  	end
	  end

	  def since(dt_from)
	  	self.range(dt_from,Time.now)
	  end

	end
end

require 'sqlite3'
require "point_sqlite3"
module Chawk
	class SqliteChawkboard
		DB_PROTOCOL_VERSION = "0.0.1"
		attr_reader :db
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
		end

		def usable_db_version?
			rows = db.execute("SELECT version FROM db_version;")
			return(rows[0][0] == DB_PROTOCOL_VERSION)
		end
	end
	class SqlitePointer 
	  attr_accessor :path
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
	    #puts "PATH: #{path}"
	    @history = []#(1..25).collect{|x|rand(100)}
	  end

	  def address
	    @path.join("/")
	  end

	  def +(other = 1)
	  	raise ArgumentError unless other.integer?
	  	self << self.last.value + other
	  end  

	  def -(other = 1)
	  	raise ArgumentError unless other.integer?
	  	self << self.last.value - other
	  end  

	  def <<(args)
	  	if args.is_a?(Array)
			#puts "ARGS: #{args}"
	  		args.each do |arg|
	  			if arg.is_a?(Integer)
	  				p = SqlitePoint.new(self,arg)
	  				@history << p
	  			else
	  				#puts "ARGS/ARG ERROR: #{arg}"
	  				raise ArgumentError
	  			end
	  		end
	  	else
			if args.is_a?(Integer)
				p = SqlitePoint.new(self,args)
	  			@history << p
			else
	  			#puts "ARG ERROR: #{arg}"
  				raise ArgumentError
  			end
	  	end
	  	self.last
	  end

	  def last
	  	return @history[-1]
	  end

	  def clear_history!
	  	@history.clear
	  end

	  def length
	  	@history.length
	  end

	  def max
	  	@history.max_by{|a|a.value}
	  end

	  def min
	  	@history.min_by{|a|a.value}
	  end

	end
end

module Chawk
	class Vaddr
		include Addressable
		attr_reader :store, :path
		def initialize(store, path)
			@store = store
			@path = path

			def model
				Chawk::Models::ValueNode
			end

			unless path.is_a?(Array)
				raise ArgumentError
			end

			unless path.reject{|x|x.is_a?(String)}.empty?
				raise ArgumentError
			end

			unless path.select{|x|x.include?('/')}.empty?
				raise ArgumentError
			end

			@node = find_or_create_addr(path)
		end
		
		def root_node
			@store.root_node
		end

		def length
			@node.values.length
		end

		def clear_history!
			Chawk::Models::Value.all(value_node_id:@node.id).destroy
		end

		def _insert(val,ts,options={})
			#raise "#{val}, #{ts}" 
			@node.values.create(value:val,observed_at:ts)

			#sql = "insert into value values (NULL,#{val},#{@node_id},'#{ts.to_i }')"
			#@board.db.execute(sql)
			#@board.add_to_notification_queue(@node_id,self.address) unless options[:supress_notify]
		end

		def <<(args)
			dt = Time.now
			if args.is_a?(Array)
				args.each do |arg|
					if arg.is_a?(Integer)
						self._insert(arg,dt)
					else
						raise ArgumentError
					end
				end
			else
				if args.is_a?(Integer)
					_insert(args,dt)
				else
					raise ArgumentError
				end
			end
			self.last
		end

	  def +(other = 1)
	  	raise ArgumentError unless other.is_a?(Numeric) && other.integer?
	  	int = (self.last.value.to_i + other.to_i)
	  	self << int
	  end  

	  def -(other = 1)
	  	raise ArgumentError unless other.is_a?(Numeric) && other.integer?
	  	int = (self.last.value.to_i - other.to_i)
	  	self << int
	  end  

	  def last(count=1)
	  	if count == 1
	  		if @node.values.length > 0
		  		VValue.new(self, @node.values.last)
		  	else
		  		nil
		  	end
		else
			vals = @node.values.all(limit:count,order:[:observed_at.asc, :id.asc])
			last_items = vals.each.collect{|val|VValue.new(self, @node.values.last)}			
		end
	  end

	  def max
		Chawk::Models::Value.max(:value)
	  end

	  def min
		Chawk::Models::Value.min(:value)
	  end

	end

	class VValue
		attr_reader :vaddr, :value, :timestamp
		def initialize(vaddr, value)
			@vaddr = vaddr
			@value = value.value
			@timestamp = value.observed_at
		end
	end

	class VRange
	end
end
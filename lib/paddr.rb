module Chawk
	class Paddr
		include Addressable
		attr_reader :store, :path, :node
		def initialize(store, path)
			@store = store
			@path = path

			def model
				Chawk::Models::PointNode
			end

			unless path.is_a?(Array)
				raise ArgumentError
			end

			unless path.reject{|x|x.is_a?(String)}.empty?
				raise ArgumentError
			end

			unless path.select{|x|x !~ /^\w+$/}.empty?
				raise ArgumentError
			end

			@node = find_or_create_addr(path)
		end
		
		def root_node
			@store.root_node
		end

		def length
			@node.points.length
		end

		def clear_history!
			Chawk::Models::Value.all(value_node_id:@node.id).destroy
		end

		def _insert(val,ts,options={})
			DataMapper.logger.debug "PREINSERT PADDR #{val} -- #{ts.to_f}"
			@node.points.create(value:val,observed_at:ts.to_f)
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
	  		if @node.points.length > 0
		  		VValue.new(self, @node.points.last)
		  	else
		  		nil
		  	end
		else
			vals = @node.points.all(limit:count,order:[:observed_at.asc, :id.asc])
			last_items = vals.each.collect{|val|VValue.new(self, @node.points.last)}			
		end
	  end

	  def max
	  	@node.points.max(:value)
	  end

	  def min
	  	@node.points.min(:value)
	  end

	  def range(dt_from, dt_to,options={})
		vals = @node.points.all(:observed_at.gte => dt_from, :observed_at.lte =>dt_to, limit:1000,order:[:observed_at.asc, :id.asc])
		vals.each.collect{|val|PPoint.new(self, @node.points.last)} unless vals.nil?
	  end

	  def since(dt_from)
	  	self.range(dt_from,Time.now)
	  end

	end

	class PPoint
		attr_reader :paddr, :value, :timestamp
		def initialize(vaddr, value)
			@vaddr = vaddr
			@value = value.value
			@timestamp = value.observed_at
		end
		def to_i
			@value
		end
	end

	class PRange
	end
end
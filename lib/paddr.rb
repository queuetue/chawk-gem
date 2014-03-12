module Chawk
	class Paddr
		include Addressable

		def _insert(val,ts,options={})
			DataMapper.logger.debug "PREINSERT PADDR #{val} -- #{ts.to_f}"
			@node.points.create(value:val,observed_at:ts.to_f)
		end

		def clear_history!
			Chawk::Models::Point.all(point_node_id:@node.id).destroy
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
		  		PPoint.new(self, @node.points.last)
		  	else
		  		nil
		  	end
		else
			vals = @node.points.all(limit:count,order:[:observed_at.asc, :id.asc])
			last_items = vals.each.collect{|val|PPoint.new(self, val)}
		end
	  end

  	  def length
	  	@node.points.length
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
		include DataPoint

		def to_i
			@value
		end
		def to_int
			@value
		end
	end

	class PRange
	end
end
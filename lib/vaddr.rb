module Chawk
	class Vaddr

		def initialize(addr)
			@addr = addr
			@node = addr.node
		end

		def _insert(val,ts,options={})
			DataMapper.logger.debug "PREINSERT VADDR #{val.length} -- #{ts.to_f}"
			@node.values.create(value:val,observed_at:ts.to_f)
		end

		def clear_history!
			Chawk::Models::Value.all(node_id:@node.id).destroy
		end

		def length
			@node.values.length
		end

		def <<(args)
			dt = Time.now
			if args.is_a?(Array)
				args.each do |arg|
					if arg.is_a?(String)
						self._insert(arg,dt)
					else
						raise ArgumentError
					end
				end
			else
				if args.is_a?(String)
					_insert(args,dt)
				else
					raise ArgumentError
				end
			end
			self.last
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

	  def range(dt_from, dt_to,options={})
		vals = @node.values.all(:observed_at.gte => dt_from, :observed_at.lte =>dt_to, limit:1000,order:[:observed_at.asc, :id.asc])
		vals.each.collect{|val|VValue.new(self, @node.values.last)} unless vals.nil?
	  end

	  def since(dt_from)
	  	self.range(dt_from,Time.now)
	  end

	end

	class VValue
		attr_reader :paddr, :value, :timestamp
		def initialize(vaddr, value)
			@vaddr = vaddr
			@value = value.value
			@timestamp = value.observed_at
		end

		def to_s
			@value
		end
		def to_str
			@value
		end
	end

	class VRange
	end
end
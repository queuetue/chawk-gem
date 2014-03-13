module Chawk
	module Store

		def initialize(addr)
			@addr = addr
			@node = addr.node
		end

		def _insert(val,ts,options={})
			#DataMapper.logger.debug "PREINSERT #{val} -- #{ts.to_f}"

			values = {value:val,observed_at:ts.to_f,agent:@addr.agent}
			values[:meta] = options[:meta] if options[:meta]

			coll.create(values)
		end

		def clear_history!
			model.all(node_id:@node.id).destroy
		end

		def length
			coll.length
		end

		def <<(args,options={})
			dt = Time.now
			if args.is_a?(Array)
				args.each do |arg|
					if arg.is_a?(stored_type)
						self._insert(arg,dt,options)
					else
						raise ArgumentError
					end
				end
			else
				if args.is_a?(stored_type)
					_insert(args,dt,options)
				else
					raise ArgumentError
				end
			end
			self.last
		end

	  def last(count=1)
	  	if count == 1
	  		if coll.length > 0
	  			coll.last
		  		#PPoint.new(self, coll.last)
		  	else
		  		nil
		  	end
		else
			vals = coll.all(limit:count,order:[:observed_at.asc, :id.asc])
			#last_items = vals #.each.collect{|val|PPoint.new(self, val)}
		end
	  end

	  def range(dt_from, dt_to,options={})
		vals = coll.all(:observed_at.gte => dt_from, :observed_at.lte =>dt_to, limit:1000,order:[:observed_at.asc, :id.asc])
		return vals
	  end

	  def since(dt_from)
	  	self.range(dt_from,Time.now)
	  end

	end
end


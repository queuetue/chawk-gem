module Chawk
	# The base store object, included by both Chawk::Vaddr and Chawk::Paddr
	# To add a custom datastore, you would begin here.
	module Store

		# @param addr [Chawk::Addr] an address instance created from Chawk#addr.
		def initialize(addr)
			@addr = addr
			@node = addr.node
		end

		# @param val [Object] value to store at this address.
		# @param ts [Time::Time]
		# @param options [Hash] Meta and Source information can be stored as well.
		# This is an internal function to add a value to the datastore and specify the observed_at time.  It can be used 
		# by external code, but do so carefully.
		def _insert(val,ts,options={})
			#DataMapper.logger.debug "PREINSERT #{val} -- #{ts.to_f}"

			values = {value:val,observed_at:ts.to_f,agent:@addr.agent}
			values[:meta] = options[:meta] if options[:meta]

			coll.create(values)
		end

		# This will clear out all of the data stored at this address for this datastore.  Use with caution.
		def clear_history!
			model.all(node_id:@node.id).destroy
		end

		# The number of stores data points in this datastore at this address.
		def length
			coll.length
		end

		def insert_recognizer(item, dt, options={})
			case 

			when item.is_a?(stored_type)
				_insert item,dt, options
			when item.is_a?(Array)
				if item.length == 2 && item[0].is_a?(stored_type) #value, timestamp
					_insert item[0],item[1], options
				else
					raise ArgumentError, "Array Items must be in [value,timestamp] format. #{item.inspect}"
				end
			when item.is_a?(Hash)
				if item['v'] && item['v'].is_a?(stored_type)
					if item['t']
						_insert item['v'],item['t'], options
					else
						_insert item['v'],dt, options
					end
				else
					raise ArgumentError, "Hash must have 'v' key set to proper type.. #{item.inspect}"
				end
			else
				raise ArgumentError, "Can't recognize format of data item. #{item.inspect}"
			end
		end

		# @param args [Object, Array of Objects]
		# @param options [Hash] You can also pass in :meta and :timestamp 
		# Add an item or an array of items (one at a time) to the datastore.
		def <<(args,options={})
			options[:observed_at] ? dt = options[:observed_at] : dt = Time.now
			if args.is_a?(Array)
				args.each do |arg|
					insert_recognizer(arg, dt, options)
				end
			else
				insert_recognizer(args, dt, options)
			end
			self.last
		end

		# @param count [Integer] returns an array with the last [0..count] items in the datastore.  If set to 1 or left empty, this returns a single item.
		# Either the last item added to the datastore or an array of the last n items added to the datastore.
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

		# Returns items whose observed_at times fit within from a range.
		# @param dt_from [Time::Time] The start time.
		# @param dt_to [Time::Time] The end time.
		# @return [Array of Objects] 
		def range(dt_from, dt_to,options={})
			vals = coll.all(:observed_at.gte => dt_from, :observed_at.lte =>dt_to, limit:1000,order:[:observed_at.asc, :id.asc])
			return vals
		end

		# Returns items whose observed_at times fit within from a range ending now.
		# @param dt_from [Time::Time] The start time.
		# @return [Array of Objects] 
		def since(dt_from)
			self.range(dt_from,Time.now)
		end

	end
end


module Chawk
	module Addressable

		def find_or_create_node(parent,name)
			#TODO: AUTHENTICATION / PERMISSIONS
			if parent.nil?
				node = model.create(name:name)
			else
				node = parent.children.first(name:name)
				node ? node : parent.children.create(name:name)
			end
			return node
		end

		def find_or_create_addr(addr)
			#TODO also accept regex-tested string
			raise ArgumentError unless addr.is_a?(Array)
			ary = addr.dup
			parent = root_node
			while ary.length > 0
				level = ary.shift
				parent = find_or_create_node(parent,level)
			end
			return parent
		end

		def address
			@path.join("/")
		end
	end
end
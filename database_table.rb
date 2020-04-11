class DatabaseTable
	def initialize
		@table = Array.new
		#No need for mutexes yet
		#the index number of each element acts as order_id
	end

	attr_accessor :table

	def insert(hash)
		new_obj = {id: last_id+1}
		@table.push(new_obj.merge(hash)) #presume input is valid and sanitized
		get(last_id)
	end

	def where(hash = {}) #returns a new table under matching the criteria in the hash
		return @table.dup if hash == {} #performance preference, stylistic drawback
		return @table.reject do |item|
			if item.nil? 
				true  #We do not want blank rows filling our queries now //ux
			elsif hash.keys.any?{ |key| (hash[key] != item[key]) }
				true
			else
			  false
			end
		end
	end

	def get(id)
		@table.at(id)
	end

	def update(id, hash)
		new_obj = get(id).merge(hash)
		@table[id] = new_obj
	end

	def delete(id)
		@table[id] = nil
	end

	def each(&block)
        @table.each(&block)
    end

    def count
    	@table.count
    end

    private

	def last_id
		@table.count - 1
	end

end
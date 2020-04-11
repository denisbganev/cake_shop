module BasicDebuggerHelper
	def debugger(obj)
	    clear_output
	    puts obj
	    puts "cont?"
	    gets
	end
end
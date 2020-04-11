require_relative "database_table_test"
require_relative "orders_test"
require_relative "cake_program_test"

class Tests
	def run
		DatabaseTableTest.new.run
		# confirm?
		puts
		OrdersTest.new.run
		# confirm?
		puts
		CakeProgramTest.new.run
	end

	def confirm?
		puts "CONTINUE?"
		gets
	end
end
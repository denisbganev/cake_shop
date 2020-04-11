require_relative "orders"

require_relative "helpers/io_helper"
#require_relative "helpers/basic_debugger_helper"

require 'date'

class CakeProgram
  include IOHelper

  #include BasicDebuggerHelper

  def initialize
    @orders = Orders.new
  end

  attr_accessor :orders

  def run
    loop do
      clear_output
      @orders.print_active_orders
      print_separator
      print_commands
      char = capture_character
      print_separator
      sleep(0.19)
      case char
      when "q", "Q"
        clear_output
        break
      when "N", "n"
        input_new_order
      when "D", "d"
        input_void_order
      when "C", "c"
        input_complete_order
      when "H", "h"
        show_cakes
      when "E", "e"
        export_balance_sheet
      else
      end
    end
  end

  def input_new_order
    clear_output
    puts "Type the table number and press ENTER or just press enter to cancel:"
    table_number = gets #expecting clean and safe input, will not implement double checks
    return if table_number == "\n"
    puts "Type the three-letter cake code and press ENTER:"
    cake_type = gets.chomp 
    @orders.create({cake_type: cake_type, table_number: table_number.chomp})
  end

  def input_void_order
    puts
    puts "Type the Order ID to be deleted and press ENTER or just press enter to cancel:\n"
    input = gets #expecting clean and safe input, will not implement double checks
    @orders.delete(input.chomp.to_i) unless (input == "\n") 
  end

  def input_complete_order
    puts
    puts "Type the Order ID to be completed and press ENTER or just press enter to cancel:\n"
    input = gets #expecting clean and safe input, will not implement double checks
    return if input == "\n"
    order_id = input.chomp.to_i
    order = @orders.get(order_id)
    if (order.nil? != true)
      @orders.complete(order_id) 
    elsif order[:state] != "Ready"
      print_cannot_complete
    end
  end

  def show_cakes
    clear_output
    puts Orders::CAKE_TYPES.map{|k,v| "#{k}: #{v}"}.join("\n")
    puts
    puts "Press ENTER to go back"
    gets
  end

  def export_balance_sheet
    filename = DateTime.now.strftime("balance_sheet_%H.%M_%d_%m_%y.csv")
    puts "Creating #{filename}... Please wait."
    @orders.export_balance_sheet(filename)
    clear_output
    puts "EXPORT COMPLETE: #{filename}"
    puts "press ENTER to return..."
    gets
  end

end


require_relative "../database_table"
require_relative "../orders"

require "date"

require_relative "../helpers/io_helper"

class OrdersTest
  include IOHelper

  def initialize
    $minimum_time = 1
  end

  def factory_item 
    {content: "placeholder"}
  end

  def run
    puts "Running cake program tests" #could be metaprogrammed for self.class
    # if export is made testable it would make the code about 5-10% more complex
    
    puts [
    pending_orders,
    create,
    complete,
    average_completion_time,
    prepare_order
    ].any? {|t| t == false} ? "Fail" : "Success"
  end

  def pending_orders
    puts "Testing pending_orders..."

    orders = Orders.new
    db = orders.backlog

    db.insert(factory_item.merge({state: "Ordered"}))
    db.insert(factory_item.merge({state: "Cooking"}))
    db.table.push( db.get(1) ) #cloned item not to be present
    to_be_deleted = db.insert(factory_item)
    db.delete(to_be_deleted[:id]) #nil item not to be fetched
    db.insert(factory_item.merge({state: "Complete"})) #complete item normally not present

    orders.pending_orders.count == 2
  end

  def create
    puts "Testing create..."

    orders = Orders.new
    db = orders.backlog
    orders.create({table_number: 1, cake_type: "AZN"})
    sleep(Orders::PENDING_TIME_MAX + Orders::COOKING_TIME_MAX) #in rspec's case, let does the job for this method
    
    db.count == 1 &&
    db.get(0).fetch(:table_number) == 1 &&
    db.get(0).fetch(:cake_type) == "AZN" &&
    db.get(0).fetch(:state) == "Ready"
  end

  def complete
    puts "Testing complete..."
    
    $mute_clears = true
    orders = Orders.new
    db = orders.backlog

    db.insert({state: "Ready", ordered: DateTime.now})
    with_stdout do
      orders.complete(0)
    end

    db.get(0) == nil && orders.balance_sheet.count == 1
  end

  def average_completion_time
    puts "Testing average_completion_time..."
    
    orders = Orders.new

    defaults = orders.average_completion_time("NIL")

    orders.balance_sheet.insert({cake_type: "AZN", completed_in: 2})
    orders.balance_sheet.insert({cake_type: "AZN", completed_in: 3})
    orders.balance_sheet.insert({cake_type: "AZN", completed_in: 4})
    orders.balance_sheet.insert({cake_type: "NMZ", completed_in: 10})
    computed = str_sec_min((Orders::PENDING_TIME_MAX + Orders::COOKING_TIME_MAX)/2)

    (defaults == computed) && (orders.average_completion_time("AZN") == str_sec_min((2+3+4)/3))
  end

  def prepare_order
    puts "Testing prepare_order..."
    
    orders = Orders.new
    db = orders.backlog

    db.insert({state: "Ordered", ordered: DateTime.now})

    orders.prepare_order(0)
    sleep(Orders::PENDING_TIME_MAX + Orders::COOKING_TIME_MAX) #in rspec's case, let does the job for this method

    db.get(0).fetch(:state) == "Ready"
  end

  def with_stdout
    stdout = $stdout                      # remember $stdout
    
    $stdout = File.open(File::NULL, "w")  #outs to dummy file, 
    yield                                 # pass to-be-muted block

    $stdout = stdout                      # restore $stdout
  end
  
end
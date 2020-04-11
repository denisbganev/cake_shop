require_relative "database_table"

require_relative "helpers/io_helper"
#require_relative "helpers/basic_debugger_helper"

require 'date'
require 'csv'


# Cake element structure: hash {}
# Fields:
# table_number: 1-6 or 0 for takeaway (any string, depends on the request of the shop owner
# cake_type: three letter code string
# ordered: DateTime
# state: String, among Ordered|Cooking|Ready|Completed
class Orders
  include IOHelper
  # include BasicDebuggerHelper

  def initialize
    @backlog = DatabaseTable.new #database
    @balance_sheet = DatabaseTable.new #database
  end

	attr_accessor :backlog
  attr_accessor :balance_sheet

  ## Filters, validation etc can be implemented
  CAKE_TYPES = {
    AZR: "Azure Grande",
    AZN: "Arizona Old-Time",
    QBC: "Quebec Rocky",
    STS: "Stansted Stained Glass",
    JJB: "George Bush"
  }

  BACKLOG_KEYS = ["id", "table_number", "cake_type", "ordered", "state"]

  BALANCE_SHEET_KEYS = ["id", "order_id", "cake_type", "completed_in"]

  #cook's max times, decided against separating cook in a class for code simplicity
  PENDING_TIME_MAX = 5 # set to 1 when testing
  COOKING_TIME_MAX = 10 # set to 1 when testing

  # scopes
  def pending_orders
    ( [] + #safety constraint
      @backlog.where({state: "Ordered"}) + 
      @backlog.where({state: "Cooking"}) +
      @backlog.where({state: "Ready"})
    ).compact.uniq
  end

  # CRUD core - get is implemented in the db and currently implementation is obsolete
  def create(order_details)
    order = @backlog.insert(
      {
        table_number: order_details[:table_number],
        cake_type: order_details[:cake_type].upcase,
        ordered: DateTime.now,
        state: "Ordered"
      }
    )

    prepare_order(order[:id])
  end

  def get(order_id)
    @backlog.get(order_id)
  end

  def complete(order_id)
    order = @backlog.get(order_id)
    completion_time = ((DateTime.now - order[:ordered])*24*60*60).to_i #in seconds
    
    @balance_sheet.insert(
      {
        order_id: order_id,
        cake_type: order[:cake_type],
        completed_in: completion_time
      }
    )

    @backlog.delete(order_id)

    call_client(order[:table_number])
  end

  def delete(order_id)
    @backlog.delete(order_id)
  end

  def average_completion_time(cake_type)
    cake_times = @balance_sheet.where(
      {cake_type: cake_type}
    ).map{
      |c| c[:completed_in] #pluck individual completion times
    }
    avg_prep_time = if (cake_times.nil? || cake_times.count == 0) #average cakespan
      (PENDING_TIME_MAX + COOKING_TIME_MAX)/2
    else
      (cake_times.reduce(:+) / cake_times.count) #average seconds
    end

    str_sec_min(avg_prep_time) #convert to the "Xm Ys" format for readability
  end

  def prepare_order(order_id)
    #the table update is ok here, because it doesn't break the id chain
    #I chose the sleep approach to the stdin or read jacking approach for code simplicity
    Thread.new do ###simulating the cook's terminal
      sleep((Random.new.rand(PENDING_TIME_MAX))) #0 to 5 minutes time until he starts cooking
      @backlog.update(order_id, {state: "Cooking"})
      sleep((Random.new.rand(COOKING_TIME_MAX))) #0 to 10 minutes time until it's ready
      @backlog.update(order_id, {state: "Ready"})
    end
  end

  def print_active_orders
    return if pending_orders.empty?
    puts "Unfinished orders:"
    pending_orders.each do |order|
      puts( 
        "ORDER ID: #{order[:id]} - " +
        "TABLE #{order[:table_number]} - " +
        "#{CAKE_TYPES[order[:cake_type].upcase.to_sym] || "Other"} - " + 
        #I went with Other/Undefined naming instead of validation, for ux reasons
        "#{order[:state]} - " +
        "Approx. Waiting Time: #{average_completion_time(order[:cake_type])}"
      )
    end
  end

  def export_balance_sheet(filename)
    CSV.open(filename, mode = "w+") do |csv|
      csv << BALANCE_SHEET_KEYS
      @balance_sheet.each do |hash_row|
        # no need to implement nil row handling yet
        csv << hash_row.values
      end
    end
  end

end
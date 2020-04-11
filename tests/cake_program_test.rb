require_relative "../cake_program"

class CakeProgramTest

  def run
    puts "Running cake program tests" #could be metaprogrammed for self.class
    $mute_clears = true
    puts [
      input_new_order,
      input_void_order,
      input_complete_order
     ].any? {|t| t == false} ? "Fail" : "Success"
  end

  def input_new_order
    puts "Testing input_new_order..."
    cp = CakeProgram.new
    with_io do |user|
      user.puts "0"
      user.puts "AZN"
      cp.input_new_order
    end
    (cp.orders.backlog.count == 1)
  end

  def input_void_order
    puts "Testing input_void_order..."
    cp = CakeProgram.new
    cp.orders.backlog.insert({content: "placeholder"})

    with_io do |user|
      user.puts "0"
      cp.input_void_order
    end
    (cp.orders.backlog.count == 1) && (cp.orders.backlog.get(0) == nil)
  end

  def input_complete_order
    puts "Testing input_complete_order..."
    cp = CakeProgram.new
    cp.orders.create({table_number: 1, cake_type: "AZN"})

    with_io do |user|
      user.puts "0"
      cp.input_complete_order
    end
    
    (cp.orders.backlog.get(0) == nil) && (cp.orders.balance_sheet.count == 1)
  end

  def with_io
    stdout = $stdout                     # remember $stdout
    stdin = $stdin                       # remember $stdin
    
    $stdout = File.open(File::NULL, "w") #outs to dummy file, 
    $stdin, write = IO.pipe              # create pipe assigning its "read end" to $stdin
    yield write                          # pass pipe's "write end" to block
  ensure
    write.close                          # close pipe

    $stdout = stdout                     # restore $stdout
    $stdin = stdin                       # restore $stdin
  end

end

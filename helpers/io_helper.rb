require 'Win32API' if Gem.win_platform?

module IOHelper
  def print_separator
    puts "------------------------------------------"
  end

  def clear_output
    return if $mute_clears
    Gem.win_platform? ? (system "cls") : (system "clear")
  end

  def print_commands
    #followed by a table number - 1-6 or 0 for takeaway and cake code - three letters in the cake menu
    puts "Press N to CREATE a new order\n"
    puts "Press D to VOID an order\n"
    puts "Press C to COMPLETE an order\n"
    puts "Press H to SHOW Cake Codes\n"
    puts "Press E to EXPORT balance table CSV\n"
    puts "Press Q to QUIT\n"
  end

  def call_client(table_number)
    print_error("CALLING THE CLIENT ON TABLE #{table_number}")
  end

  def print_cannot_complete
    print_error("CANNOT COMPLETE AN ORDER THAT IS NOT READY")
  end


  def print_error(message)
    8.times do |n|
      clear_output
      sleep(0.15)
      puts message
      sleep(0.15)
    end
  end

  def str_sec_min(seconds)
    "%dm %ds" % [seconds / 60 % 60, seconds % 60]
  end

  def capture_character
    if Gem.win_platform?
      char = Win32API.new('crtdll','_getch', [], 'L').Call
      return char
    else
      system("stty raw -echo")
      char = STDIN.read_nonblock(1) rescue nil
      system("stty -raw echo")
      return char
    end
  end
end
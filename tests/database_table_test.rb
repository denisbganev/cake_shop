require_relative "../database_table"

class DatabaseTableTest
  def factory_item 
    {content: "placeholder"}
  end

  def run
    puts "Running database table tests" #could be metaprogrammed for self.class
    puts [
      insert,
      delete,
      get,
      update,
      where,
    ].any? {|t| t == false} ? "Fail" : "Success"
  end

  def insert
  	puts "testing insert..."
    db = DatabaseTable.new
  	db.insert(factory_item)
  	
    db.count==1 
  end

  def delete
    puts "testing delete..."
    db = DatabaseTable.new
    db.insert({id: 0}.merge(factory_item))
    db.delete(0)
    
    (db.count==1 && db.get(0) == nil)
  end

  def get
    puts "testing get..."
    db = DatabaseTable.new
    db.insert({id: 0}.merge(factory_item))
    
    db.get(0)==db.table[0]
  end

  def update
    puts "testing update..."
    db = DatabaseTable.new
    db.insert({id: 0}.merge(factory_item))
    db.update(0, {content: "new_content"})
    
    db.get(0)[:content] == "new_content"
  end

  def where
    puts "testing where..."
    db = DatabaseTable.new
    db.insert({id: 0, findable: true}.merge(factory_item))
    db.insert({id: 1, findable: false}.merge(factory_item))
    db.insert({id: 2, findable: true}.merge(factory_item))
    
    db.where({findable: true}).count == 2
  end
end

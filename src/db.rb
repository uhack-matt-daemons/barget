require "sqlite3"

class DB 
	def initialize() 
		# Open a database
		@db = SQLite3::Database.new "sqlite.db"

		# Create a database
		rows = @db.execute <<-SQL
			CREATE TABLE IF NOT EXISTS users(
					id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
					name VARCHAR(30)
					);
		SQL
		rows = @db.execute <<-SQL
			CREATE TABLE IF NOT EXISTS stuff(
					id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
					userID INTEGER,
					itemID CHAR(11)
					);
		SQL
  end
	def user_add(name)
		@db.execute "INSERT INTO users (name) VALUES (?)",name
	end
	def stuff_add(user,item)
		@db.execute "INSERT INTO stuff (userID, itemID) VALUES (?,?)",user,item
  end

  def user_items(id)
    @db.execute "SELECT * FROM stuff WHERE userID = ?", id
  end

  def user_get(id)
    @db.execute "SELECT * FROM users WHERE id = ?", id
  end

  def user_find(name)
    @db.execute "SELECT * FROM users WHERE name = ?", name
  end
end

$db = DB.new()

class User
  attr_accessor :name
  def initialize(data)
    @id = data[0]
    @name = data[1]
  end

  def items
    $db.user_items(@id).map do |row|
      row[2]
    end
  end


  def self.get(id)
    res = $db.user_get id
    res.size == 1 ? User.new(res[0]) : nil
  end

  def self.find(name)
    res = $db.user_find name
    res.size == 1 ? User.new(res[0]) : nil
  end
end

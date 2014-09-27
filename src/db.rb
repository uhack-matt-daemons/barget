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
					itemID CHAR(11),
					timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
					expired INTEGER DEFAULT 0
					);
		SQL
	end
	def user_add(name)
		@db.execute "INSERT INTO users (name) VALUES (?)",name
	end
	def item_add(user,item)
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
	def populate()
		@db.execute("INSERT INTO users (name) VALUES ('Dave'),('Joe')")
		@db.execute("INSERT INTO stuff (userID,itemID) VALUES (1,'080-00-1464'),(2,'080-00-1464'),(1,'203-60-0820'),(2,'203-60-0820')")
		@db.execute("INSERT INTO stuff (userID,itemID,timestamp) VALUES (2,'080-00-1464','2010-12-12'),(2,'080-00-1464','2011-4-20'),(2,'212-30-0283','2011-6-10'),(2,'212-30-0283','2011-6-17'),(2,'212-30-0283','2012-7-24'),(2,'212-30-0283','2011-12-25');")
		# return @db.execute("SELECT * from stuff,users");
	end

	#array of items purchased by same perosn more than once
	def repeatItemsUser(id)
		@db.execute("SELECT A.* FROM stuff A WHERE A.userID = ? AND EXISTS (SELECT B.itemID FROM stuff B WHERE B.userID = A.userID AND B.itemID = A.itemID AND A.id != B.id) ORDER BY timestamp DESC",id);
	end
	#all users
	def repeatItems()
		@db.execute("SELECT A.* FROM stuff A WHERE EXISTS (SELECT B.itemID FROM stuff B WHERE B.userID = A.userID AND B.itemID = A.itemID AND A.id != B.id) ORDER BY timestamp DESC");
	end
end

$db = DB.new

class User
	attr_accessor :name, :id
	def initialize(data)
		@id = data[0]
		@name = data[1]
	end

	def add_item(item_id)
		$db.item_add(@id, item_id)
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

class Analytics
	def self.user(id)
		grouped_items = $db.repeatItemsUser(id).group_by {|i| i[2]}
		@item_stats = {}
		grouped_items.each {|id,_| @item_stats[id] = {}}
		grouped_items.each do |id,ids|
			i=0
			diff=0
			while i< (ids.length-1) do
				day2 = DateTime.parse(ids[i+1][3]).yday
				day1 = DateTime.parse(ids[i][3]).yday
				diff = diff + (day2 - day1).abs
				i = i + 1
			end
			diff = diff/i
			@item_stats[id][:average_diff] = diff
			@item_stats[id][:popularity] = i
			@item_stats[id][:most_recent_add] = ids[0][3]
			@item_stats[id][:expected_expiration_in] = Date.parse(ids[0][3]) + diff
		end
		@item_stats
	end

	def self.global()
		grouped_items = $db.repeatItems().group_by {|i| i[2]}
		@item_stats = {}
		grouped_items.each {|id,_| @item_stats[id] = {}}
		grouped_items.each do |id,ids|
			i=0
			diff=0
			while i< (ids.length-1) do
				day2 = DateTime.parse(ids[i+1][3]).yday
				day1 = DateTime.parse(ids[i][3]).yday
				diff = diff + (day2 - day1).abs
				i = i + 1
			end
			diff = diff/i
			@item_stats[id][:average_diff] = diff
			@item_stats[id][:popularity] = i
		end
		@item_stats
		
	end
end

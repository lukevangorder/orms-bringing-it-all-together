class Dog
    attr_accessor :name, :breed, :id
    def initialize(name:, breed:, id:nil)
        @name = name
        @breed = breed
        @id = id
    end
    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs
            (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
        SQL
        DB[:conn].execute(sql)
    end
    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end
    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (? , ?)
        SQL
        DB[:conn].execute(sql, [@name, @breed])
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        Dog.new(name: @name, breed: @breed, id: @id)
    end
    def self.create(name:, breed:)
        created_dog = Dog.new(name: name, breed: breed)
        created_dog.save
    end
    def self.new_from_db(row)
        Dog.new(name: row[1], breed: row[2], id: row[0])
    end
    def self.find_by_id(search_id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL
        row = DB[:conn].execute(sql, [search_id])[0]
        Dog.new(name: row[1], breed: row[2], id: row[0])
    end
    def self.find_or_create_by(name:, breed:)
        search = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ?', [name, breed])[0]
        if search == nil
            Dog.create(name: name, breed: breed)
        else
            Dog.new(name: search[1], breed: search[2], id: search[0])
        end
    end
    def self.find_by_name(search)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
        SQL
        row = DB[:conn].execute(sql, [search])[0]
        Dog.new(name: row[1], breed: row[2], id: row[0])
    end
    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, [@name, @breed, @id])
    end
end
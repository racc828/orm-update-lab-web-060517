require_relative "../config/environment.rb"

require "pry"

class Student

  attr_reader :id
  attr_accessor :name, :grade

  def initialize(name, grade, id = nil)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql =  <<-SQL
        CREATE TABLE students (
          id INTEGER PRIMARY KEY,
          name TEXT,
          grade INTEGER
          )
          SQL
      DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
    sql = <<-SQL
      INSERT INTO students(name, grade)
      VALUES(?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT id FROM students WHERE name = ?", self.name).flatten.first
    end
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students")
  end

  def self.new_from_db(row)
    new_student = Student.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
   sql = <<-SQL
    UPDATE students
    SET name = ?, grade = ?
    WHERE id = ?
   SQL
   DB[:conn].execute(sql, self.name, self.grade, self.id)
 end

end

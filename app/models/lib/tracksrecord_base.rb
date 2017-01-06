require 'active_support/inflector'
require_relative 'db_connection'
require_relative 'associatable'
require_relative 'relation'
require_relative 'searchable'

class TracksrecordBase
  extend Associtable
  extend Searchable

  def self.columns
    return @columns if @columns

    columns = DBConnection.execute2(<<-SQL).first
      SELECT
        *
      FROM
        #{self.table_name}
      LIMIT
        0
    SQL
    columns.map!(&:to_sym)
    @columns = columns
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) do
        self.attributes[column]
      end

      define_method("#{column}=") do |value|
        self.attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.tableize
  end

  def initialize(params = {})
    params.each do |name, value|
      name = name.to_sym
      if self.class.columns.include?(name)
        self.send("#{name}=", value)
      else
        raise "unknown attribute '#{name}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |attr| self.send(attr) }
  end

  def destroy
    DBConnection.execute(<<-SQL, id)
      DELETE FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
    SQL

    self
  end


  def self.destroy_all
    self.all.each { |row| row.destroy }
  end


  def insert
    columns = self.class.columns.drop(1)
    col_names = columns.map(&:to_s).join(", ")
    question_marks = ((["?"]) * columns.count).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    updates = self.class.columns.map { |attr| "#{attr} = ?" }.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{updates}
      WHERE
        #{self.class.table_name}.id = ?
    SQL
  end

  def save
    id.nil? ? insert : update
  end

  private
  def columns
    self.class.columns
  end

  def table_name
    self.class.table_name
  end
end

module Searchable
  def where(params)
    where_line = params.keys.map { |key| "#{key} = ? " }.join(" AND ")

    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL

    parse_all(results)
  end

  def all
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL

    parse_all(results)
  end

  def find_by_sql(sql, values = [])
    results = DBConnection.execute(sql, values)
    parse_all(results)
  end

  def find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        #{self.table_name}.id = ?
    SQL

    parse_all(results).first
  end

  def find_by(conditions)
    self.where(conditions).first
  end

  def first
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      LIMIT
        1
    SQL

    results
  end

  def last
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      ORDER BY
        id DESC
      LIMIT 1
    SQL

    results
  end

  def method_missing(method_name, *args)
    if method_name.to_s.start_with?("find_by_")
      columns = method_name[8..-1].split('_and_')

      conditions = {}
      columns.size.times { |i| conditions[columns[i]] = args[i] }

      all.where(conditions).limit(1).first
    else
      all.send(method_name, *args)
    end
  end

  def parse_all(results)
    results.map { |result| self.new(result) }
  end


end

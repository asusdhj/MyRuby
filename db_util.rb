require 'mysql'

#-----------数据库操作----------------#
class DBUtil
  def initialize
    @userName = "root"
    @password = "948567"
    @dbName = "baidu"
    @host = "localhost"
    @port = 3306
  end

  #------连接数据库------#
  def getConnection
    @dbh = Mysql.real_connect(@host,@userName,@password,@dbName,@port)
    rescue Exception => e     #异常处理
    puts e.message

    return dbh
  end

  #----------关闭数据库连接--------#
  def closeConnection
    @dbh.close if @dbh
  rescue Exception => e
    e.message
  end


  #-------创建title表---------#
  def createTitleTable id
    t_name = "T_"
    t_name.concat id.to_s
     create = <<SQL
create table if not exists #{t_name}(
id int(8) NOT NULL,                #创建title和link表
title varchar(50),
link int(100),
PRIMARY KEY (id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8
SQL

    if @dbh
      begin
        @dbh.query('set names utf8')    #为了解决乱码
      @dbh.query(create)
      puts "success"
      return true
      rescue Exception => e
      puts e.message
      puts "1111111"
      return false
      end

    end
  end

  #-------创建关键字表---------#
  def createKeyTable
    create = <<SQL
create table if not exists T_key(
id int(8)  NOT NULL,
keyword varchar(30) NOT NULL,
status int(8),
hasSearched int(8),
PRIMARY KEY (keyword,id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8
SQL

    if @dbh
      begin
        @dbh.query(create)
        puts "success"
        return true
      rescue Exception => e
        puts e.message
        return false
      end

    end
  end

  #----------统计数据库中关键字的个数--------#
  def countKey
    sql = "select count(*) from T_key"

    if @dbh then
      begin
        count = -1
        resultSet = @dbh.query(sql)
        count = resultSet.fetch_row
      rescue Exception => e
        e.message
      ensure
        return count
      end
    end
  end

  #--------将关键字存入数据库---------#
  def insertKey relatedHash,id     #关键字以hash表的形式传入
    relatedHash.each { |key, value|
      sql = "insert into T_key values('#{id}','#{key}','#{value}',0)"
      if @dbh then
        begin
          @dbh.query('set names utf8')    #为了解决乱码
          @dbh.query(sql)
          puts "insert success"
          rescue Exception => e
            puts e.message
        end
      end
    }
  end


  #-------------------将提取的title和链接存入数据库---------------#
  def insertTitle relatedHash,id
    table = "T_"
    table.concat id.to_s
    relatedHash.each { |key, value|
      sql = "insert into #{table} values('#{id}','#{key}','#{value}')"
      if @dbh then
        begin
          @dbh.query('set names utf8')    #为了解决乱码
          @dbh.query(sql)
          @dbh.query("update T_key set hasSearched = 1 where keyword = '#{id}'")
          puts "insert success"
        rescue Exception => e
          puts e.message
        end
      end
    }
  end

  #--------从数据库中读取关键字---------#
  def readKey    #start为关键字读取开始的偏移量
    relatedHash = Hash.new
    sql = "select * from T_key where status=0 limit 10000"
    if @dbh then
      begin
        resultset = @dbh.query(sql)
        while row = resultset.fetch_row
          relatedHash.store(row[0],row[1])   #将读取的关键字写入数据库
          end
      rescue Exception => e
          puts e.message
      ensure
        return relatedHash
      end
    end
  end

  #-----------检查表中所有关键字是否有title-----#
  def isAllTaversed
    sql = "select count(*) from T_key where hasSearched = 0"
    if @dbh then
      begin
        resultSet = @dbh.query(sql)
        count = resultSet.fetch_row
      rescue Exception => e
        e.message
      ensure
        return count
      end
    end
  end


  #-------计算表中关键字的数量---------#
  def countKey    #start为关键字读取开始的偏移量
    sql = "select count(*) from T_key "
    if @dbh then
      begin
        resultSet = @dbh.query(sql)
        count = resultSet.fetch_row
      rescue Exception => e
        e.message
      ensure
        return count
      end
    end
  end


  #--------根据关键字查找ID-------------#
  def getId key
    sql = "select id from T_key where keyword = '#{key}' "
    if @dbh then
      begin
        resultSet = @dbh.query("select count(*) from T_key ")
        count = resultSet.fetch_row
        if count == 0 then
          id = 0
        else
          resultSet = @dbh.query(sql)
          while row = resultset.fetch_row
            id = row[0]   #将读取的关键字写入数据库
          end
        end
      rescue Exception => e
        e.message
      ensure
        return id
      end
    end
  end
  end



load 'grab.rb'
load 'http_connect.rb'
load "db_util.rb"
require 'thread'

hostname = "www.baidu.com"
port = 80
keyword = "123"   #关键字
@socket = HttpConnect.new hostname,port   #连接网络
@gra = Grab.new(hostname,port)      #抓取页面信息
@database = DBUtil.new    ##数据库连接
@database.getConnection   #打开数据库连接

#----------------主函数-----------------#
def mainFunctioon relatedHash
  begin
    Thread.new do
      relatedHash.each_key { |key|
        doTitle key
      }
    end
    relatedHash.replace(@gra.traverseHash(relatedHash))
    database.insertKey relatedHash if @database.createKeyTable
    relatedHash.replace(database.readKey)
  end while database.countKey > 10_0000
end

#--------将title存入数据库----------------#
def doTitle key
  response = @socket.connect key
  titleHash = @gra.getTitle response
  id = @database.getId key
  @database.insertTitle titleHash,id if @database.createTitleTable id
end


response = @socket.connect keyword  #连接网络并读取搜索悉信息
relatedHash = @gra.grabRelatedSearchHash response    #将抓取的关键字存入hash表

begin

  relatedHash.replace(@gra.traverseHash(relatedHash))
  count = @database.countKey.to_i
  if count == -1
    puts "计数错误"
    break;
  end
  count = count + 1
  @database.insertKey(relatedHash,count ) if @database.createKeyTable
  relatedHash.each_key { |key|
    doTitle key
  }
  relatedHash.replace(@database.readKey)
end while @database.countKey > 10_0000

@database.closeConnection   #关闭数据库连接


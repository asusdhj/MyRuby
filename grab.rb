load 'http_connect.rb'

#------------------------------从网页抓取信息---------------------#
class Grab
  @@related_array = Array.new
  @@count = 0
  def initialize hostname,port
    @hostname = hostname
    @port = port
  end

  #------------抓取title和链接---------#
  def getTitle response
    relatedHash = Hash.new
    for div in response.scan /<div[\s]+class="result c-container "[\s\S]*?>[\s\S]+?<\/div>/           #匹配div
      for a in div.scan /<h3\s+class="t"><a\s+?[\s\S]+?href\s*?=\s*?"([^"\s]+)"[\s\S]*?>([\s\S]+?)<\/a>\s*?(<a\s+?href\s*?=\s*?"([^"\s]+)"[\s\S]*?>([^<]+?)<\/a>)?\s*<\/h3>/     # 匹配<a></a>
        relatedHash.store(a[1].delete!("<em>","</em>"),a[0])
      end
    end
    return relatedHash
  end



  #-------抓取关键字------#
  def grabRelatedSearchHash response    #response为百度搜索返回的页面信息
    relatedHash = Hash.new
    for div in response.scan /<div[\s]id="rs">[\s\S]+<\/div>/    #匹配div
      for table in div.scan /<table[\s>][\s\S]+?<\/table>/       #匹配table
        for a in table.scan /<a\s+href="([^"\s]+)">([^<]+)<\/a>/   # 匹配<a></a>
          relatedHash.store(a[1],0)    #将结果存入hash表，0代表该关键字未被遍历
        end
      end
    end
    return relatedHash
  end

  #--------根据单个关键字抓取相关搜索--------------#
  def getKeyHash key
    socket = HttpConnect.new(@hostname,@port)
    return grabRelatedSearchHash(socket.connect(key))
  end


  #---------通过遍历已有关键字获取更多关键字-----------#
  def traverseHash relatedHash
    loop{
      if relatedHash.size >10000        #hash表一次存入10000个值
        break
      end
      for item in relatedHash
        if item[1] == 0
          value = item[0]
          break
        end
      end
      relatedHash[value] = 1
      puts value
      bufferHash = getKeyHash(value)
      relatedHash = relatedHash.merge bufferHash do |key,old,new|
        old > new ? old : new
      end
    }
    return relatedHash
  end

end



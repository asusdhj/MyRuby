require 'socket'   #引入socket库

class HttpConnect   #创建socket连接

  def initialize(hostname,port)
    @hostname = hostname
    @port = port
  end

  def connect(keyword)
    request = "GET /s?wd=#{keyword} HTTP/1.0\r\n\r\n"
    socket = TCPSocket.open(@hostname,@port)
    socket.print request
    response = socket.read
    return response
  end

end


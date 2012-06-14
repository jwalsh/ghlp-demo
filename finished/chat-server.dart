#library('chat-server');
#import('dart:io');
#import('static-file-handler.dart');

#import('dart:isolate');
#import('file-logger.dart', prefix: 'log');
#import('server-utils.dart');

class ChatHandler {
  
  Set<WebSocketConnection> connections;
  
  ChatHandler() : connections = new Set<WebSocketConnection>() {
    log.initLogging('chat-log.txt');
  }
  
  // closures!
  onOpen(WebSocketConnection conn) {
    print('new ws conn');
    connections.add(conn);
    
    conn.onClosed = (int status, String reason) {
      print('conn is closed');
      connections.remove(conn);
    };
    
    conn.onMessage = (message) {
      print('new ws msg: $message');
      connections.forEach((connection) {
        if (conn != connection) {
          queue(() => connection.send(message));
        }
      });
      time('send msg', () => log.log(message));
    };
    
    conn.onError = (e) {
      print("problem w/ conn");
      connections.remove(conn); // onClosed isn't being called ??
    };
  }
}

runServer(String basePath, int port) {
  HttpServer server = new HttpServer();
  WebSocketHandler wsHandler = new WebSocketHandler();
  wsHandler.onOpen = new ChatHandler().onOpen;
  
  server.defaultRequestHandler = new StaticFileHandler(basePath).onRequest;
  server.addRequestHandler((req) => req.path == "/ws", wsHandler.onRequest);
  server.listen('127.0.0.1', 1337);
  print('listening for connections on $port');
}

main() {
  var script = new File(new Options().script);
  var directory = script.directorySync();
  runServer("${directory.path}/static", 1337);
}

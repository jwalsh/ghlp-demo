#library('chat-server');
#import('dart:io');
#import('static-file-handler.dart');

#import('dart:isolate');
#import('file-logger.dart', prefix: 'log');
#import('utils.dart');

class ChatHandler {
  
  static int indexCounter = 0;
  Map<int, WebSocketConnection> connections;
  SendPort logger;
  
  ChatHandler() : connections = new Map<int, WebSocketConnection>(),
      logger = log.initLogging('log.txt');
  
  // closures!
  onOpen(WebSocketConnection conn) {
    final int index = indexCounter++;
    print('new ws conn $index');
    connections[index] = conn;
    
    conn.onClosed = (int status, String reason) {
      print('conn $index is closed');
      connections.remove(index);
    };
    
    conn.onMessage = (message) {
      print('new ws msg: $message from $index');
      connections.forEach((i, connection) {
        if (i != index) {
          connection.send(message);
        }
      });
      time('send msg', () => logger.send(message));
    };
    
    conn.onError = (e) {
      print("problem w/ conn $index: $e");
      connections.remove(index); // onClosed isn't being called ??
    };
  }
}

runServer(String basePath) {
  HttpServer server = new HttpServer();
  WebSocketHandler wsHandler = new WebSocketHandler();
  wsHandler.onOpen = new ChatHandler().onOpen;
  
  server.defaultRequestHandler = new StaticFileHandler(basePath).onRequest;
  server.addRequestHandler((req) => req.path == "/ws", wsHandler.onRequest);
  server.listen('127.0.0.1', 1337);
}

main() {
  File script = new File(new Options().script);
  script.directory().then((Directory d) {
    runServer(d.path);
  });
}
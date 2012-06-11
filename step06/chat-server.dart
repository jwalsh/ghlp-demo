#library('chat-server');
#import('dart:io');
#import('static-file-handler.dart');

#import('dart:isolate');
#import('file-logger.dart', prefix: 'log');
#import('utils.dart');

class ChatHandler {
  
  static int indexCounter = 0;
  Map<int, WebSocketConnection> connections;
  
  ChatHandler() : connections = new Map<int, WebSocketConnection>() {
    log.initLogging('log.txt');
  }
  
  // closures!
  onOpen(WebSocketConnection conn) {
    // Step 6: handle onError, onClosed, onMessage for conn.
    // In onMessage, send the incoming message to every other
    // connection.
    
    // Bonus: use the connections Map to index a connection
    // to a counter so you know which connection is "your" connection
  }
}

runServer(String basePath, int port) {
  HttpServer server = new HttpServer();
  // Step 6: create web socket handler, bind onOpen to ChatHandler onOpen
  
  server.defaultRequestHandler = new StaticFileHandler(basePath).onRequest;
  // Step 6: add WS request handlers to server, bound to /ws path
  server.listen('127.0.0.1', 1337);
  print('listening for connections on $port');
}

main() {
  File script = new File(new Options().script);
  script.directory().then((Directory d) {
    runServer("${d.path}/static", 1337);
  });
}

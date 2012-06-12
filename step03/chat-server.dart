#library('chat-server');
// Step 5: Import dart:io
// Step 5: import static-file-handler.dart

class ChatHandler {
  
  static int indexCounter = 0;
  Map<int, WebSocketConnection> connections;
  
  ChatHandler() : connections = new Map<int, WebSocketConnection>();
  
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
  // Step 5: create a HTTP server
  // Step 5: set default request handler to StaticFileHandler with basePath
  
  // Step 6: create web socket handler, bind onOpen to ChatHandler onOpen
  // Step 6: add WS request handlers to server, bound to /ws path
  
  // Step 5: listen on 127.0.0.1 on port
  
  print('listening for connections on $port');
}

main() {
  // Step 5: Grab the directory that this script is in,
  // and run the server with the base directory set to
  // the static dir inside of "here"
  // Hint: use the Options object to identify where the
  // script is
}

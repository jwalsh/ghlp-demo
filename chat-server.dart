#library('chat-server');

#import('dart:io');
#import('dart:isolate');
#import('file-logger.dart', prefix: 'log');
#import('server-utils.dart');
#import('dart:json');

/** Server Backend **/
class StaticFileHandler {
  final String basePath;

  StaticFileHandler(this.basePath);

  _send404(HttpResponse response) {
    response.statusCode = HttpStatus.NOT_FOUND;
    response.outputStream.close();
  }

  // TODO: etags, last-modified-since support
  onRequest(HttpRequest request, HttpResponse response) {
    final String path = request.path == '/' ? '/index.html' : request.path;
    final File file = new File('${basePath}${path}');
    file.exists().then((found) {
      if (found) {
        file.fullPath().then((String fullPath) {
          if (!fullPath.startsWith(basePath)) {
            _send404(response);
          } else {
            file.openInputStream().pipe(response.outputStream);
          }
        });
      } else {
        _send404(response);
      }
    });
  }
}

runServer(String basePath, int port) {
  HttpServer server = new HttpServer();
  WebSocketHandler wsHandler = new WebSocketHandler();
  wsHandler.onOpen = new ChatHandler(basePath).onOpen;

  server.defaultRequestHandler = new StaticFileHandler(basePath).onRequest;
  server.addRequestHandler((req) => req.path == "/ws", wsHandler.onRequest);
  server.onError = (error) => print(error);
  server.listen('127.0.0.1', 1337);
  print('listening for connections on $port');
}
/** End Server Backend **/

/** Client Interaction **/
class ChatHandler {

  Set<WebSocketConnection> connections;

  ChatHandler(String basePath) : connections = new Set<WebSocketConnection>() {
    log.initLogging('${basePath}/chat-log.txt');
  }

  // closures!
  onOpen(WebSocketConnection conn) {
    /** Websocket Init **/
    print('onOpen<WebSocketConnection>');
    connections.add(conn);
    // Give the new user a hand of numbers when they first join
    String newNumbers = generateNumber();
    var encoded = JSON.stringify({'header': "serverNumbers", 'numbers': newNumbers});
    conn.send(encoded);
    /** end Websocket Init **/

    /** websocket event handlers **/
    conn.onClosed = (int status, String reason) {
      print('conn.onClosed: $reason');
      connections.remove(conn);
    };

    conn.onMessage = (message) {
      print('conn.onMessage: $message');
      connections.forEach((connection) {
        if (conn != connection) {
          print('queued msg to be sent');
          queue(() => connection.send(message));
        }
      });
      time('send to isolate', () => log.log(message));
    };

    conn.onError = (e) {
      print("problem w/ conn");
      connections.remove(conn); // onClosed isn't being called ??
    };

    // Game status
    _sendGameState(mesg) {
      connections.forEach((connection) {
        if (conn != connection) {
          print('queued msg to be sent');
          queue(() => conn.send('publishGameState(): $mesg'));
        }
      });
      new Timer.repeating(5000, _sendGameState('{status: {currentPlayer, currentTimeout, bid: {count, value, player}}}'));
    }
  }
}

/** End Client Interaction **/

/** Game **/
final gameNumberSize = 5;
var gameNumbers;
var rankCounts;

class Player {
  var gameNumber;
  String playerName;

  // player constructor
  Player(name) : playerName = name;

  // Called when a new game is started
  newNumber(){
    gameNumber = generateNumber();
  }

  num get playerNum() => gameNumber;

}

String generateNumber(){
  var numbers = (Math.random() * Math.pow(10, gameNumberSize)).toInt().toString();
  var buffer = gameNumberSize - numbers.length;
  var pad = "";
  for(var i = 0; i < buffer; i++){
    pad = pad.concat("0");
  }
  numbers = pad.concat(numbers);
  gameNumbers.add(numbers);
  print(numbers);
  return numbers;
}

void createCounts(){
  initCounts();
  var rank;
  var players = gameNumbers.length;
  for(var i = 0; i < players; i++){
    String playerN = gameNumbers[i];
    var len = playerN.length;
    for(var k = 0; k < len; k++){
      rank = Math.parseInt(playerN[k]);
      //print(rank);
      rankCounts[rank]++;
    }
  }
}

void initCounts(){
  rankCounts.clear();
  // 10 total loops for each 0 to 9th digit
  for(var i = 0; i <= 9; i++){
    rankCounts.add(0);
  }
}

void printCounts(){
  var len = rankCounts.length;
  for(var i = 0; i < len; i++){
    print('$i: ${rankCounts[i]}');
  }
}

class Game {
}
/** End Game **/

main() {
  gameNumbers = [];
  rankCounts = [];

  var script = new File(new Options().script);
  var directory = script.directorySync();
  runServer("${directory.path}/client", 1337);
}


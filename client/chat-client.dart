#library('chat-client');

#import('dart:html');
#import('dart:json');

ChatConnection chatConnection;
MessageInput messageInput;
UsernameInput usernameInput;
ChatWindow chatWindow;
BidButton bidButton;
LiarButton liarButton;
SpanElement yourNumbersElem;

class ChatConnection {
  WebSocket webSocket;
  String url;

  ChatConnection(this.url) {
    _init();
  }

  sendBid(String userName, String bidCount, String bidValue) {
    var encoded = JSON.stringify({'header': "clientBid", 'userName': userName, 'bidCount': bidCount, 'bidValue': bidValue});
    _sendEncodedMessage(encoded);
  }

  sendLiar(String userName) {
    var encoded = JSON.stringify({'header': "clientLiar", 'userName': userName, 'liar': true});
    _sendEncodedMessage(encoded);
  }

  sendJoin() {
    var encoded = JSON.stringify({'header': "clientJoin"});
    _sendEncodedMessage(encoded);
  }

  _receivedEncodedMessage(String encodedMessage) {
    Map message = JSON.parse(encodedMessage);

    if(message['header'] == "serverNumbers") {
      yourNumbersElem.innerHTML = message['numbers'];
    }

    if (message['userName'] != null) {
      chatWindow.displayMessage(message['userName'], "Server");
    }
  }

  _sendEncodedMessage(String encodedMessage) {
    if (webSocket != null && webSocket.readyState == WebSocket.OPEN) {
      webSocket.send(encodedMessage);
    } else {
      print('WebSocket not connected, message $encodedMessage not sent');
    }
  }

  _init([int retrySeconds = 2]) {
    bool encounteredError = false;
    chatWindow.displayNotice("Welcome to Liar's Poker");
    webSocket = new WebSocket(url);

    webSocket.on.open.add((e) {
      chatWindow.displayNotice('You are now playing.');
      // New player request
      //chatConnection.sendJoin();
    });

    webSocket.on.close.add((e) {
      chatWindow.displayNotice('web socket closed, retrying in $retrySeconds seconds');
      if (!encounteredError) {
        window.setTimeout(() => _init(retrySeconds*2), 1000*retrySeconds);
      }
      encounteredError = true;
    });

    webSocket.on.error.add((e) {
      chatWindow.displayNotice("Error connecting to ws");
      if (!encounteredError) {
        window.setTimeout(() => _init(retrySeconds*2), 1000*retrySeconds);
      }
      encounteredError = true;
    });

    webSocket.on.message.add((MessageEvent e) {
      print('received message ${e.data}');
      _receivedEncodedMessage(e.data);
    });
  }
}

abstract class View<T> {
  final T elem;

  View(this.elem) {
    bind();
  }

  // bind to event listeners
  void bind() { }
}

class BidButton extends View<InputElement> {
  BidButton(InputElement elem) : super(elem);

  disable() {
    elem.disabled = true;
  }

  enable() {
    elem.disabled = false;
  }

  // Sends {user: username, bidCount: bidCount, bidValue: bidValue} to Server
  // Display the username to chatWindow
  bind() {
    elem.on.click.add((e) {
      String count = messageInput.bidCount;
      String value = messageInput.bidValue;
      String message = "Bid [Count: $count, Value: $value]";
      chatConnection.sendBid(usernameInput.username, count, value);
      chatWindow.displayMessage(message, usernameInput.username);
    });
  }

  String get bidCount() => elem.value[0];
  String get bidValue() => elem.value[1];
}

class LiarButton extends View<InputElement> {
  LiarButton(InputElement elem) : super(elem);

  diable() {
    elem.disabled = true;
  }

  enable() {
    elem.disabled = false;
  }

  bind() {
    elem.on.click.add((e) {
      String message = "LIAR!";
      chatConnection.sendLiar(usernameInput.username);
      chatWindow.displayMessage(message, usernameInput.username);
    });
  }
}

class MessageInput extends View<InputElement> {
  MessageInput(InputElement elem) : super(elem);

  disable() {
    elem.disabled = true;
    elem.value = 'Enter username';
  }

  enable() {
    elem.disabled = false;
    elem.value = '';
  }

  String get bidCount() => elem.value[0];
  String get bidValue() => elem.value[1];
}

class UsernameInput extends View<InputElement> {
  UsernameInput(InputElement elem) : super(elem);

  bind() {
    elem.on.change.add((e) => _onUsernameChange());
  }

  _onUsernameChange() {
    if (!elem.value.isEmpty()) {
      messageInput.enable();
    } else {
      messageInput.disable();
    }
  }

  String get username() => elem.value;
}

class ChatWindow extends View<TextAreaElement> {
  ChatWindow(TextAreaElement elem) : super(elem);

  displayMessage(String msg, String from) {
    _display("$from: $msg\n");
  }

  displayNotice(String notice) {
    _display("[system]: $notice\n");
  }

  _display(String str) {
    elem.text = "${elem.text}$str";
  }
}

main() {
  TextAreaElement chatElem = query('#chat-display');
  InputElement usernameElem = query('#chat-username');
  InputElement messageElem = query('#chat-message');
  InputElement bidElem = query('#bidButton');
  InputElement liarElem = query('#liarButton');
  yourNumbersElem = query('#yourNumbers');

  bidButton = new BidButton(bidElem);
  liarButton = new LiarButton(liarElem);
  chatWindow = new ChatWindow(chatElem);
  usernameInput = new UsernameInput(usernameElem);
  messageInput = new MessageInput(messageElem);
  chatConnection = new ChatConnection("ws://127.0.0.1:1337/ws");
}
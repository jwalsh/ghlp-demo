#library('chat-client');
#import('dart:html');
#import('dart:json');
#import('lawndart/lib/lawndart.dart');

WebSocket ws;
MessageInput messageInput;
UsernameInput usernameInput;
ChatWindow chatWindow;
Store<String, Dynamic> database;
Store<String, Dynamic> delayedMessagesDb;
ChatSink chatSink;

abstract class View<T> {
  final T elem;
  
  View(T this.elem) {
    bind();
  }
  
  // bind to event listeners
  void bind() { }
  
  // load from the database
  Future init() => new Future.immediate(true);
}

class MessageInput extends View<InputElement> {
  MessageInput(InputElement elem) : super(elem);
  
  disable() {
    elem.disabled = true;
    elem.value = 'enter username';
  }
  
  enable() {
    elem.disabled = false;
    elem.value = '';
  }
  
  String get message() => elem.value;
  
  bind() {
    elem.on.change.add((e) {
      chatSink.sendMessage(message, usernameInput.username);
      elem.value = '';
    });
  }
}

class UsernameInput extends View<InputElement> {
  UsernameInput(InputElement elem) : super(elem);
  
  bind() {
    elem.on.change.add((e) => _onUsernameChange());
  }
  
  Future init() {
    Completer completer = new Completer();
    database.getByKey("username").then((value) {
      print("got username $value");
      if (value != null) {
        elem.value = value;
        _enableMessageInput();
      }
      elem.disabled = false;
      completer.complete(true);
    });
    return completer.future;
  }
  
  _onUsernameChange() {
    database.save(username, "username");
    ws.send(JSON.stringify({'usernameChange': username}));
    _enableMessageInput();
  }
  
  _enableMessageInput() {
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
    elem.text += "$from: $msg\n";
  }
}

class ChatSink {
  bool isOnline = false;
  
  sendMessage(String message, String from, [String resendKey = null]) {
    if (ws.readyState == WebSocket.CLOSED && !isOnline) {
      var key = resendKey == null ? new Date.now().value.toString() : resendKey;
      Future saved = delayedMessagesDb.save(message, key);
      saved.handleException((e) => print("Error saving msg: $e"));
      saved.then((e) => print('saved message to local db'));
      message = "$message (delayed)";
    } else {
      ws.send(JSON.stringify({'f': usernameInput.username, 'm': message}));
    }
  
    chatWindow.displayMessage(message, usernameInput.username);
  }
  
  reconnected() {
    isOnline = true;
    if (ws.readyState != WebSocket.OPEN) {
      isOnline = false;
      return;
    }
    delayedMessagesDb.keys().then((List keys) {
      for (var key in keys) {
        print('found old message key $key');
        delayedMessagesDb.getByKey(key).then((value) {
          if (!isOnline) return;
          sendMessage(value, usernameInput.username, resendKey:key);
          delayedMessagesDb.removeByKey(key);
        });
      }
    });
  }
  
  disconnected() {
    isOnline = false;
  }
}

void initWebSocket() {
  ws = new WebSocket('ws://localhost:1337/ws');
  
  ws.on.open.add((e) {
    print('web socket connected');
    chatSink.reconnected();
  });
  
  ws.on.close.add((e) {
    print('web socket closed');
    chatSink.disconnected();
    window.setTimeout(initWebSocket, 1000);
  });
  
  ws.on.error.add((e) {
    print("Error connecting to ws");
    window.setTimeout(initWebSocket, 1000);
  });
  
  ws.on.message.add((e) {
    print('received message ${e.data}');
    var msg = JSON.parse(e.data);
    print(msg);
    if (msg['f'] != null) {
      chatWindow.displayMessage(msg['m'], msg['f']);
    }
  });
}

Future initElements() {
  Completer completer = new Completer();
  Futures.wait([chatWindow, messageInput, usernameInput].map((i) => i.init())).then((_) {
    completer.complete(true);
  });
  return completer.future;
}

main() {
  chatWindow = new ChatWindow(document.query('#chat-display'));
  messageInput = new MessageInput(document.query('#chat-input'));
  usernameInput = new UsernameInput(document.query('#chat-username'));
  IndexedDb idb = new IndexedDb("chat-db", ["chat-db", "delayed-messages"], "4");
  chatSink = new ChatSink();
  
  idb.open()
  .chain((_) {
    database = idb.store("chat-db");
    delayedMessagesDb = idb.store("delayed-messages");
    return new Future.immediate(true);
  })
  .chain((_) => initElements())
  .then((_) => initWebSocket());
}
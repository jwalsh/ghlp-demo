#library('chat-client');

#import('dart:html');
#import('dart:json');

WebSocket ws;
MessageInput messageInput;
UsernameInput usernameInput;
ChatWindow chatWindow;

abstract class View<T> {
  final T elem;
  
  View(this.elem) {
    bind();
  }
  
  // bind to event listeners
  void bind() { }
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
  
  String get message() => elem.value;
  
  bind() {
    elem.on.change.add((e) {
      ws.send(JSON.stringify({'f': usernameInput.username, 'm': message}));
      chatWindow.displayMessage(message, usernameInput.username);
      elem.value = '';
    });
  }
}

class UsernameInput extends View<InputElement> {
  UsernameInput(InputElement elem) : super(elem);
  
  bind() {
    elem.on.change.add((e) => _onUsernameChange());
  }
  
  _onUsernameChange() {
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
    _display("$from: $msg\n");
  }
  
  displayNotice(String notice) {
    _display("[system]: $notice\n");
  }
  
  _display(String str) {
    elem.text = "${elem.text}$str";
  }
}

void initWebSocket([int retrySeconds = 2]) {
  chatWindow.displayNotice("Connecting to Web socket");
  ws = new WebSocket('ws://localhost:1337/ws');
  
  ws.on.open.add((e) {
    chatWindow.displayNotice('Connected');
  });
  
  ws.on.close.add((e) {
    chatWindow.displayNotice('web socket closed, retrying in $retrySeconds seconds');
    window.setTimeout(() => initWebSocket(retrySeconds*2), 1000*retrySeconds);
  });
  
  ws.on.error.add((e) {
    chatWindow.displayNotice("Error connecting to ws");
    window.setTimeout(() => initWebSocket(retrySeconds*2), 1000*retrySeconds);
  });
  
  ws.on.message.add((e) {
    print('received message ${e.data}');
    var msg = JSON.parse(e.data);
    if (msg['f'] != null) {
      chatWindow.displayMessage(msg['m'], msg['f']);
    }
  });
}

main() {
  chatWindow = new ChatWindow(document.query('#chat-display'));
  usernameInput = new UsernameInput(document.query('#chat-username'));
  messageInput = new MessageInput(document.query('#chat-input'));
  
  initWebSocket();
}
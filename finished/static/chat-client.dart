#library('chat-client');
#import('dart:html');
#import('dart:json');

WebSocket ws;
MessageInput messageInput;
UsernameInput usernameInput;
ChatWindow chatWindow;

abstract class View {
  final Element parent;
  
  View(this.parent) {
    create();
    bind();
  }
  
  abstract void create();
  
  // bind to event listeners
  void bind() { }
}

class MessageInput extends View {
  InputElement elem;
  MessageInput(Element parent) : super(parent);
  
  create() {
    var div = new DivElement();
    div.nodes.add(new Text("Message:"));
    elem = new InputElement();
    elem.id = 'chat-message';
    elem.type = 'text';
    elem.disabled = true;
    div.elements.add(elem);
    parent.elements.add(div);
  }
  
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

class UsernameInput extends View {
  InputElement elem;
  UsernameInput(Element parent) : super(parent);
  
  create() {
    var div = new DivElement();
    div.nodes.add(new Text("Username"));
    elem = new InputElement();
    elem.id = 'chat-username';
    elem.type = 'text';
    div.elements.add(elem);
    parent.elements.add(div);
  }
  
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

class ChatWindow extends View {
  TextAreaElement elem;
  ChatWindow(Element parent) : super(parent);
  
  create() {
    var div = new DivElement();
    elem = new TextAreaElement();
    elem.id = 'chat-display';
    elem.rows = 10;
    elem.cols = 100;
    elem.disabled = true;
    div.elements.add(elem);
    parent.elements.add(div);
  }
  
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
    print(msg);
    if (msg['f'] != null) {
      chatWindow.displayMessage(msg['m'], msg['f']);
    }
  });
}

main() {
  chatWindow = new ChatWindow(document.body);
  usernameInput = new UsernameInput(document.body);
  messageInput = new MessageInput(document.body);
  
  initWebSocket();
}
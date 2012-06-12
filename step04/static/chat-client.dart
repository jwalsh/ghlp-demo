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
    // Step 4, handle the change event on the element.
    // Step 4, display a message in the chat window when this
    //         element changes, and then blank out this input field
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
    // Step 4, enable the message input when a username
    //         is added. If the username field is empty,
    //         disable the message input field.
  }
  
  _onUsernameChange() {
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
  // Step 7: create a web socket connection, handle four events
  // get new messages and print them to the text area
}

main() {
  chatWindow = new ChatWindow(document.body);
  usernameInput = new UsernameInput(document.body);
  messageInput = new MessageInput(document.body);
  
  initWebSocket();
}
#library('chat-client');

#import('dart:html');
#import('dart:json');

ChatConnection chatConnection;
MessageInput messageInput;
UsernameInput usernameInput;
ChatWindow chatWindow;

class ChatConnection {
  // Step 06, add webSocket instance field
  String url;
  
  ChatConnection(this.url) {
    _init();
  }
  
  send(String from, String message) {
    var encoded = JSON.stringify({'f': from, 'm': message});
    _sendEncodedMessage(encoded);
  }
  
  _receivedEncodedMessage(String encodedMessage) {
    Map message = JSON.parse(encodedMessage);
    if (message['f'] != null) {
      chatWindow.displayMessage(message['m'], message['f']);
    }
  }
  
  _sendEncodedMessage(String encodedMessage) {
    // Step 6, send the message over the WebSocket
  }
  
  _init() {
    // Step 6, connect to the WebSocket, listen for events
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
      chatConnection.send(usernameInput.username, message);
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

main() {
  chatWindow = new ChatWindow(document.query('#chat-display'));
  usernameInput = new UsernameInput(document.query('#chat-username'));
  messageInput = new MessageInput(document.query('#chat-message'));
  chatConnection = new ChatConnection("ws://127.0.0.1:1337/ws");
}
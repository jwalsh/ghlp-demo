#library('chat-client');

#import('dart:html');

// Step 5, import the JSON library

// Step 6, rename this object
ChatConnection connection;
MessageInput messageInput;
UsernameInput usernameInput;
ChatWindow chatWindow;

class ChatConnection {
  // Step 7, add webSocket instance field
  String url;
  
  ChatConnection(this.url) {
    _init();
  }
  
  send(String from, String message) {
    // Step 5, encode from and message into one JSON string
  }
  
  _receivedEncodedMessage(String encodedMessage) {
    // Step 5, decode a JSON string and display it in the chat window
  }
  
  _sendEncodedMessage(String encodedMessage) {
    // Step 7, send the message over the WebSocket
  }
  
  _init() {
    // Step 7, connect to the WebSocket, listen for events
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
  
  bind() {
    elem.on.change.add((e) {
      connection.send(usernameInput.username, message);
      chatWindow.displayMessage(message, usernameInput.username);
      elem.value = '';
    });
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
  chatWindow = new ChatWindow(chatElem);
  usernameInput = new UsernameInput(usernameElem);
  messageInput = new MessageInput(messageElem);
  
  connection = new ChatConnection("ws://127.0.0.1:1337/ws");
}
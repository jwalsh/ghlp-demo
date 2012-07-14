#library('chat-client');

#import('dart:html');

// Step 5, import the JSON library

// Step 6, rename this object
ChatConnection connection;
MessageInput messageInput;
UsernameInput usernameInput;

// Step 3, Very first edit
// Step 3, add variable for chat window

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
    // Step 4, when the message input changes,
    // send the message, display the message, and clear the message input
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
    // Step 4, handle change event for username input
  }
  
  _onUsernameChange() {
    // Step 4, enable the message input if username input
    // is not empty, or disable the message input if username input
    // is empty
  }
  
  String get username() => elem.value;
}

// Step 3, define the ChatWindow class

main() {
  // Step 4, identify elements by ID
  TextAreaElement chatElem = null;
  InputElement usernameElem = null;
  InputElement messageElem = null;
  // Step 3, instantiate chatWindow
  usernameInput = new UsernameInput(usernameElem);
  messageInput = new MessageInput(messageElem);

  connection = new ChatConnection("ws://127.0.0.1:1337/ws");
}
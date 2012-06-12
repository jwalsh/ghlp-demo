#library('chat-client');
#import('dart:html');
#import('dart:json');


MessageInput messageInput;
UsernameInput usernameInput;
ChatWindow chatWindow;

abstract class View<T> {
  final T elem;
  
  View(T this.elem) {
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
    // Step 4, handle the change event on the element.
    // Step 4, display a message in the chat window when this
    //         element changes, and then blank out this input field
  }
}

class UsernameInput extends View<InputElement> {
  UsernameInput(InputElement elem) : super(elem);
  
  bind() {
    // Step 4, enable the message input when a username
    //         is added. If the username field is empty,
    //         disable the message input field.
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

  // Step 7: create a web socket connection, handle four events
  // get new messages and print them to the text area
}

main() {
  chatWindow = new ChatWindow(document.query('#chat-display'));
  messageInput = new MessageInput(document.query('#chat-input'));
  usernameInput = new UsernameInput(document.query('#chat-username'));
  
  initWebSocket();
}
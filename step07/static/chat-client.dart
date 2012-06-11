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
    elem.on.change.add((e) {
      // Step 7: send the message over the web socket
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
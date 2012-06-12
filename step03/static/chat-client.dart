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
    // Step 3:
    // create the equivalent of:
    // Message: <input type="text" id="chat-message" disabled>
    // wrap it all in a div
    // and add the div to the parent element
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
    // Step 3:
    // create the equivalent of
    // Username: <input type="text" id="chat-username">
    // wrap it in a div
    // and attach the div to the parent
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
    // Step 3:
    // create the equivalent of <textarea id="chat-display" rows="10" cols="100" disabled></textarea>
    // wrap it in a div and attach the div to the parent
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
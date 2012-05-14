#library('chat-client');
#import('dart:html');
#import('dart:json');

WebSocket ws;
MessageInput messageInput;
UsernameInput usernameInput;
ChatWindow chatWindow;

abstract class View<T> {
  final T elem;
  
  View(T this.elem) {
    bind();
  }
  
  abstract bind();
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
      ws.send(JSON.stringify({'f': usernameInput.username, 'm': message}));
      chatWindow.displayMessage(message, usernameInput.username);
      elem.value = '';
    });
  }
}

class UsernameInput extends View<InputElement> {
  UsernameInput(InputElement elem) : super(elem);
  
  bind() {
    elem.on.change.add((e) {
      ws.send(JSON.stringify({'usernameChange': elem.value}));
      if (!elem.value.isEmpty()) {
        messageInput.enable();
      } else {
        messageInput.disable();
      }
    });
  }
  
  String get username() => elem.value;
}

class ChatWindow extends View<TextAreaElement> {
  ChatWindow(TextAreaElement elem) : super(elem);
  
  displayMessage(String msg, String from) {
    elem.text += "$from: $msg\n";
  }
  
  bind() => null;
}

main() {
  chatWindow = new ChatWindow(document.query('#chat-display'));
  messageInput = new MessageInput(document.query('#chat-input'));
  usernameInput = new UsernameInput(document.query('#chat-username'));
  ws = new WebSocket('ws://localhost:1337/ws');
  
  ws.on.message.add((e) {
    var msg = JSON.parse(e.data);
    print(msg);
    if (msg['f'] != null) {
      chatWindow.displayMessage(msg['m'], msg['f']);
    }
  });

}
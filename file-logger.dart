#library('file-logger');
#import('dart:isolate');
#import('dart:io');
#import('utils.dart');

startLogging() {
  print('started logger');
  File log;
  OutputStream out;
  port.receive((msg, replyTo) {
    print('received $msg');
    if (log == null) {
      log = new File(msg);
      out = log.openOutputStream(FileMode.APPEND);
    } else {
      time('writeString', () {
        out.writeString("${new Date.now()} : $msg\n");
      });
    }
  });
}

SendPort initLogging(String logFileName) {
  SendPort send = spawnFunction(startLogging);
  port.receive((msg, replyTo) => print('enable it to work')); // ???
  send.send(logFileName);
  return send;
}
#library('server-utils');

#import('dart:io');

time(msg, callback()) {
  var sw = new Stopwatch.start();
  callback();
  sw.stop();
  print('Timing for $msg: ${sw.elapsedInUs()} us');
}

// runs the callback on the event loop at the next opportunity
queue(callback()) {
  new Timer(0, (t) => callback());
}
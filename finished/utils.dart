#library('utils');

time(msg, callback()) {
  var sw = new Stopwatch.start();
  callback();
  sw.stop();
  print('Timing for $msg: ${sw.elapsedInUs()} us');
}
final gameNumberSize = 5;
var gameNumbers;
var rankCounts;


class player {
  var gameNumber;
  String playerName;
  
  // player constructor
  player(name) : playerName = name;
  
  // Called when a new game is started
  newNumber(){
    gameNumber = generateNumber();
  }
  
  num get playerNum() => gameNumber;
   
}

String generateNumber(){
  var numbers = (Math.random() * Math.pow(10, gameNumberSize)).toInt().toString();
  var buffer = gameNumberSize - numbers.length;
  var pad = "";
  for(var i = 0; i < buffer; i++){
    pad = pad.concat("0");
  }  
  numbers = pad.concat(numbers);
  gameNumbers.add(numbers);
  print(numbers);
  return numbers;
}

void createCounts(){
  initCounts();
  var rank;
  var players = gameNumbers.length;
  for(var i = 0; i < players; i++){
    String playerN = gameNumbers[i];
    var len = playerN.length;
    for(var k = 0; k < len; k++){
      rank = Math.parseInt(playerN[k]);
      //print(rank);
      rankCounts[rank]++;
    }      
  }
}

void initCounts(){
  rankCounts.clear();
  // 10 total loops for each 0 to 9th digit
  for(var i = 0; i <= 9; i++){
    rankCounts.add(0);
  }
}

void printCounts(){
  var len = rankCounts.length;
  for(var i = 0; i < len; i++){
    print('$i: ${rankCounts[i]}');
  }
}

class game { 
  
  
}


main(){
  gameNumbers = [];
  rankCounts = [];
  generateNumber();
  createCounts();
  //printCounts();
}




import std.conv, std.string, std.getopt, std.format,
  std.array, std.c.stdlib;
import field;
import ai, ui, exception;

void main(string[] args)
{
  enum Player{PERSON, COM}
  int dim = 6;
  int numpo = 10000;
  getopt(args,
	 "d",  &dim,
	 "p",  &numpo
	 );
  
  Field fd = Field(dim);
  AI ai =  new AI(numpo);
  UI ui = new CUI();  
  ui.display(fd);

  auto whoWon = delegate(int x, Player p)
    {
      if(fd.isWin(x)){
	if(p == Player.PERSON){
	  ui.output("Player Win!");
	}else{
	  ui.output("Computer Win!");
	}
	fd.clear();
	ui.output("Press any key...");
	ui.input();
	ui.display(fd);
      }else if(fd.isFull()){
	ui.output("Draw!");
	fd.clear();
	ui.input();
	ui.display(fd);
      }
    };
  
  while(true){
    string[] cmd = ui.input();
    while(cmd.length == 0){
      cmd = ui.input();
    }
    switch(cmd[0]){
    case "put" :
      if(cmd.length != 2){
	ui.output("Wrong number of argument.");
	break;
      }
      try{
	fd.put(to!int(cmd[1]));
      }catch(OutOfFieldException e){
	break;
      }catch(FullColumnException e){
	break;
      }
      ui.display(fd);
      whoWon(to!int(cmd[1]), Player.PERSON);
      break;
    case "unput" :
      try{
	fd.unput();
      }catch(NoHistoryException e){
	break;
      }
      ui.display(fd);
      break;
    case "clear":
      fd.clear();
      ui.display(fd);
      break;
    case "display":
      ui.display(fd);
      break;
    case "com":
      Decision dec = ai.play(fd);
      try{
	fd.put(dec.x);
      }catch(OutOfFieldException e){
	exit(1);
      }catch(FullColumnException e){
	exit(1);
      }
      ui.showAIStatus(dec.valid_places);
      auto outstr = appender!string();
      formattedWrite(outstr, "Chose %s.", dec.x);
      ui.output(outstr.data);
      ui.display(fd);
      whoWon(dec.x, Player.COM);
      break;
    case "turn":
      auto outstr = appender!string();
      formattedWrite(outstr, "%s's turn.", fd.turn == RED ? "RED" : "YELLOW");
      ui.output(outstr.data);
      break;
    case "dim":
      if(cmd.length == 2){
	try{
	  fd.setDim(to!int(cmd[1]));
	}catch(NonPositiveException e){
	  break;
	}
	ui.display(fd);
      }else{
	ui.output("Wrong number of argument.");
      }
      break;
    case "numpo":
      if(cmd.length == 2){
	try{
	  ai.setNumPlayout(to!int(cmd[1]));
	}catch(NonPositiveException e){
	  break;
	}
      }else{
	ui.output("Wrong number of argument.");
      }
      break;
    case "quit":
      return;
    default:
      ui.output("No such command.");
      break;
    }
    ui.output("");
  }
}

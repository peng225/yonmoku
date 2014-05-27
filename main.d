import std.conv, std.string, std.getopt, std.format,
  std.array, std.c.stdlib;
import std.stdio;
import field;
import ai, ui, exception;

void main(string[] args)
{
  int dim = 6;
  int po = 10000;
  getopt(args,
	 "d",  &dim,
	 "p",  &po
	 );
  
  Field fd = Field(dim);
  AI ai =  new AI(po);
  UI ui = new CUI();  
  ui.display(fd);  
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
      if(fd.isWin(to!int(cmd[1]))){
	ui.output("Player Win!");	
	fd.clear();
	ui.output("Press any key...");
	readln();
	ui.display(fd);
      }else if(fd.isFull()){
	ui.output("Draw!");
	fd.clear();
	readln();
	ui.display(fd);
      }
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
      if(fd.isWin(dec.x)){
      	ui.output("Computer Win!");
      	fd.clear();
      	ui.output("Press any key...");
      	readln();
      	ui.display(fd);
      }else if(fd.isFull()){
      	ui.output("Draw!");
      	fd.clear();
	ui.output("Press any key...");
      	readln();
      	ui.display(fd);
      }
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
    case "po":
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
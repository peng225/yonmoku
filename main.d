import std.conv, std.string, std.getopt, std.format, std.array;
import std.stdio;
import field;
import ai;
import ui;

void main(string[] args)
{
  int dim = 6;
  getopt(args,
	 "d",  &dim
	 );
  
  Field fd = Field(dim);
  AI ai =  new AI(10);
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
      if(!fd.put(to!int(cmd[1]))){
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
      fd.unput();
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
      fd.put(dec.x);
      ui.showAIStatus(dec.valid_places);
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
	fd.setDim(to!int(cmd[1]));
	ui.display(fd);
      }else{
	ui.output("Wrong number of argument.");
      }
      break;
    case "numpo":
      if(cmd.length == 2){
	ai.setNumPlayout(to!int(cmd[1]));
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
import std.stdio;
import std.conv;
import std.string;
import std.getopt;
import field;
import ai;

void main(string[] args)
{
  int dim = 6;
  getopt(args,
	 "d",  &dim
	 );
  
  Field fd = Field(dim);
  AI ai =  new AI(10000);
  fd.show();
  while(true){
    string[] cmd;
    string tcmd;
    while((tcmd = chop(readln())) == ""){
    }
    cmd = split(tcmd);
    switch(cmd[0]){
    case "put" :
      if(cmd.length != 2){
	writeln("Wrong number of argument.");
	break;
      }
      if(!fd.put(to!int(cmd[1]))){
	break;
      }      
      fd.show();
      if(fd.isWin(to!int(cmd[1]))){
	writeln("Player Win!");	
	fd.clear();
	writeln("Press any key...");
	readln();
	fd.show();
      }else if(fd.isFull()){
	writeln("Draw!");
	fd.clear();
	readln();
	fd.show();
      }
      break;
    case "clear":
      fd.clear();
      fd.show();
      break;
    case "show":
      fd.show();
      break;
    case "com":
      int ai_x = ai.play(fd);
      fd.put(ai_x);
      fd.show();
      if(fd.isWin(ai_x)){
	writeln("Computer Win!");
	fd.clear();
	writeln("Press any key...");
	readln();
	fd.show();
      }else if(fd.isFull()){
	writeln("Draw!");
	fd.clear();
	readln();
	fd.show();
      }
      break;
    case "turn":
      writefln("%s's turn.", fd.turn == RED ? "RED" : "YELLOW");
      break;
    case "dim":
      if(cmd.length == 2){
	fd.setDim(to!int(cmd[1]));
	fd.show();
      }else{
	writeln("Wrong number of argument.");
      }
      break;
    case "numpo":
      if(cmd.length == 2){
	ai.setNumPlayout(to!int(cmd[1]));
      }else{
	writeln("Wrong number of argument.");
      }
      break;
    case "quit":
      return;
    default:
      writeln("No such command.");
      break;
    }
    writeln("");    

    // ここで勝利判定をしなければならない
  }
}
import std.stdio, std.string, std.conv, std.format, std.array, std.c.stdlib;
import field, place;

interface UI
{
  string[] input();
  void output(string msg);
  void display(Field fd);
  void showAIStatus(Place[int] valid_places);
}

class CUI : UI
{
  string[] input()
  {
    string input_str = chop(readln());
    if(input_str.length == 0){
      return [];
    }else{
      return split(input_str);
    }    
  }
  
  void output(string msg)
  {
    writeln(msg);
  }

  void display(Field fd)
  {
    string outstr;
    for(int i = 0; i < fd.dim; i++){
      outstr ~= " " ~ to!string(i);      
    }
    output(outstr);
    
    for(int i; i < fd.dim; i++){
      outstr = "|";
      for(int j; j < fd.dim; j++){
	switch(fd.get(j, i)){
	case BLANK:
	  outstr ~= " |";
	  break;
	case RED:
	  outstr ~= "r|";
	  break;
	case YELLOW:
	  outstr ~= "y|";
	  break;
	default:
	  output("Unknown value is included in the field.");
	  exit(1);
	  break;
	}
      }
      output(outstr);
    }
    output("");
  }

  void showAIStatus(Place[int] valid_places)
  {
    foreach(i, var; valid_places){
      writefln("%s %s %s", i, var.n, var.ucb);
    }
  }

  unittest{
    // CUI ui = new CUI();
    // string[] cmd = ui.input();
    // auto output = appender!string();
    // formattedWrite(output, "%s is the ultimate %s.", cmd[0], cmd[1]);
    // ui.output(output.data);
  }
}
import std.stdio, std.algorithm, std.conv, std.math, std.random;
import field;

struct Place
{
  int x;
  int n;
  double reward;
  double ucb;

  // @property int n(){return m_n;}
  // @property double ucb(double val){return m_ucb = val;}
  
  this(int x){
    this.x = x;
    ucb = double.max;
    reward = 0.;
  }
  
  int opCmp(ref const Place s) const
  {
    return s.ucb < this.ucb;
  }

  int opEqauls(ref const Place s) const
  {
    return s.ucb == this.ucb;
  }
}

class AI
{
  private int num_playout;
  private immutable double draw_reward;

  private double playout(Field fd, int x)
  {
    auto my_turn = fd.turn;
    fd.put(x);
    if(fd.isWin(x)){
      if(my_turn == fd.reverseTurn()){
	return 1.;
      }else{
	return 0.;
      }
    }
    while(!fd.isFull()){
      auto tx = uniform(0, fd.dim);
      while(!fd.isEmpty(tx)){
	tx = uniform(0, fd.dim);
      }
      fd.put(tx);
      if(fd.isWin(tx)){
	if(my_turn == fd.reverseTurn()){
	  return 1.;
	}else{
	  return 0.;
	}
      }
    }
    return draw_reward;
  }
  
  this(int num_playout)
  {
    this.num_playout = num_playout;
    draw_reward = 0.4;
  }

  void setNumPlayout(int num_playout)
  {
    this.num_playout = num_playout;
  }
  
  int play(Field fd)
  {
    Place[int] valid_places;
    for(int i = 0; i < fd.dim; i++){
      if(fd.isEmpty(i)){
	valid_places[i] = Place(i);
      }
    }

    int num_all_playouts = 0;
    for(int i; i < num_playout; i++){
      // writefln("%s-th playout.", i);

      // foreach(var; valid_places){
      // 	writefln("x: %s ucb: %s", var.x, var.ucb);
      // }
      
      // idx == xであることに注意
      // 本当はこんな気持ち悪いことしたくないんだが...
      auto idx = reduce!(max)(valid_places).x;
      // writefln("idx is %s.", idx);
      
      double result = playout(fd, idx);
      // writefln("result is %s.", result);
      num_all_playouts++;
      valid_places[idx].n++;
      valid_places[idx].reward += result;
      foreach(ref var; valid_places){
	if(var.n != 0){
	  var.ucb = var.reward / var.n
	    + sqrt(2. * log(num_all_playouts) / var.n);
	}
      }
    }

    foreach(i, var; valid_places){
      writefln("%s %s %s", i, var.n, var.ucb);
    }
    
    return reduce!(max)(valid_places).x;
  }

  unittest{
    writeln("ai unittest begin.");
    AI ai = new AI(100);
    Field fd = Field(5);
    Field fd2 = fd;
    fd.put(0);
    fd.show();
    auto x = ai.play(fd);
    fd.put(x);
    fd.show();
    writeln("ai unittest end.");
  }
}
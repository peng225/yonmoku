import std.algorithm, std.conv, std.math, std.random;
import std.stdio;
import field, place;

struct Decision
{
  Place[int] valid_places;
  int x;
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
  
  Decision play(Field fd)
  {
    Place[int] valid_places;
    for(int i = 0; i < fd.dim; i++){
      if(fd.isEmpty(i)){
	valid_places[i] = Place(i);
      }
    }

    int num_all_playouts = 0;
    for(int i; i < num_playout; i++){

      auto x = reduce!(max)(valid_places).x;
      
      double result = playout(fd, x);
      num_all_playouts++;
      valid_places[x].n++;
      valid_places[x].reward += result;
      foreach(ref var; valid_places){
	if(var.n != 0){
	  var.ucb = var.reward / var.n
	    + sqrt(2. * log(num_all_playouts) / var.n);
	}
      }
    }
    
    Decision dec;
    dec.valid_places = valid_places;
    dec.x = reduce!(max)(valid_places).x;    
    
    return dec;
  }

  unittest{
  }
}
import std.algorithm, std.conv, std.math, std.random;
import std.stdio;
import field, place;

alias Place[int] Status;

struct Decision
{
  Place[int] valid_places;
  int x;
}

class AI
{
  private int num_playout;
  private immutable double draw_reward;
  private Status[hash_t] st;
  // private Status[Field] st;

  this(int num_playout)
  {
    this.num_playout = num_playout;
    draw_reward = 0.4;
  }

  void setNumPlayout(int num_playout)
  {
    this.num_playout = num_playout;
  }

  // private double playout(Field fd, int x)
  // {
  //   auto my_turn = fd.turn;
  //   fd.put(x);
  //   if(fd.isWin(x)){
  //     if(my_turn == fd.reverseTurn()){
  // 	return 1.;
  //     }else{
  // 	return 0.;
  //     }
  //   }
  //   while(!fd.isFull()){
  //     auto tx = uniform(0, fd.dim);
  //     while(!fd.isEmpty(tx)){
  // 	tx = uniform(0, fd.dim);
  //     }
  //     fd.put(tx);
  //     if(fd.isWin(tx)){
  // 	if(my_turn == fd.reverseTurn()){
  // 	  return 1.;
  // 	}else{
  // 	  return 0.;
  // 	}
  //     }
  //   }
  //   return draw_reward;
  // }

  private double random_playout(Field fd, int depth)
  {
    auto my_turn = (depth % 2 == 0 ? fd.turn : fd.reverseTurn());
    int num_rplayouts = 0;
    double result = draw_reward;
    while(!fd.isFull()){
      auto tx = uniform(0, fd.dim);
      while(!fd.isEmpty(tx)){
  	tx = uniform(0, fd.dim);
      }
      fd.put(tx);
      num_rplayouts++;
      if(fd.isWin(tx)){
  	if(my_turn == fd.reverseTurn()){
  	  result = 1.;
	  break;
  	}else{
  	  result = 0.;
	  break;
  	}
      }
    }
    for(int i = 0; i < num_rplayouts; i++){
      fd.unput();
    }
    writeln("Random playout done.");
    return result;
  }

  // 終盤になるとrandom_playoutに入る前に盤がfullになる可能性あり
  // オブジェクトの参照を渡しているので、ハッシュ値がすべて同じになっているorz
  private double playout(Field fd, int depth, int num_all_playouts)
  {
    if(depth > log(to!double(num_playout)/(fd.dim + 1)) / log(fd.dim)){
    // if(depth > 1){
      writeln("Get into random palyout.");
      return random_playout(fd, depth);
    }else{
      // 盤面ハッシュにまだ情報がなかったら追加する
      writefln("hash %s", fd.toHash());
      if(fd.toHash() !in st){
	writeln("Add board information to st.");
	Place[int] valid_places;
	for(int i = 0; i < fd.dim; i++){
	  if(fd.isEmpty(i)){
	    valid_places[i] = Place(i);
	  }
	}
	st[fd.toHash()] = valid_places;
      }
      // foreach(var; st[fd]){
      // 	writefln("var: %s", var);
      // }
      auto x = reduce!(max)(st[fd.toHash()]).x;
      writefln("Chose %s.", x);
      assert(fd.toHash() in st);
      fd.put(x);
      depth++;
      double result = playout(fd, depth, num_all_playouts);
      fd.unput();
      assert(fd.toHash() in st);
      st[fd.toHash()][x].n++;
      st[fd.toHash()][x].reward += result;      
      foreach(ref var; st[fd.toHash()]){
  	if(var.n != 0){
  	  var.ucb = var.reward / var.n
  	    + sqrt(2. * log(num_all_playouts + 1) / var.n);
  	}
      }      
      return result;
    }
  }

  Decision play(Field fd)
  {	
    int num_all_playouts = 0;        
    for(int i; i < num_playout; i++){
      playout(fd, 0, num_all_playouts);
      num_all_playouts++;
    }

    writeln("All playout done.");

    Decision dec;
    dec.valid_places = st[fd.toHash()];
    dec.x = reduce!(max)(dec.valid_places).x;    

    st.clear();
    return dec;
  }
  
  // Decision play(Field fd)
  // {
  //   Place[int] valid_places;
  //   for(int i = 0; i < fd.dim; i++){
  //     if(fd.isEmpty(i)){
  // 	valid_places[i] = Place(i);
  //     }
  //   }

  //   int num_all_playouts = 0;
  //   for(int i; i < num_playout; i++){

  //     auto x = reduce!(max)(valid_places).x;
      
  //     double result = playout(fd, x);
  //     num_all_playouts++;
  //     valid_places[x].n++;
  //     valid_places[x].reward += result;
  //     foreach(ref var; valid_places){
  // 	if(var.n != 0){
  // 	  var.ucb = var.reward / var.n
  // 	    + sqrt(2. * log(num_all_playouts) / var.n);
  // 	}
  //     }
  //   }
    
  //   Decision dec;
  //   dec.valid_places = valid_places;
  //   dec.x = reduce!(max)(valid_places).x;    
    
  //   return dec;
  // }

  unittest{
    // AI ai1 = new AI(1000);
    // AI ai2 = new AI(1000);
    // writeln(ai1);
    // writeln(ai2);
  }
}
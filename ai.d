import std.algorithm, std.conv, std.math, std.random, std.datetime, std.c.stdlib;
import field, place;
import exception;
import ui;

alias Place[int] Status;
UI cui = new CUI();

enum{DRAW_REWARD = 0.4, WIN_REWARD = 1., LOSE_REWARD = 0.};

struct Decision
{
  Place[int] valid_places;
  int x;
}

// エラー処理

class AI
{
  private int num_playout;  
  private Status[Field] st;

  this(int num_playout)
  {
    this.num_playout = num_playout;
  }

  void setNumPlayout(int num_playout)
  {
    if(num_playout <= 0){
      throw new NonPositiveException("Non positive error",
				     num_playout);
    }
    this.num_playout = num_playout;
  }

  private double random_playout(Field fd, int depth)
  {
    auto my_turn = (depth % 2 == 0 ? fd.turn : fd.reverseTurn());
    int num_rplayouts = 0;
    double result = DRAW_REWARD;
    while(!fd.isFull()){
      auto tx = uniform(0, fd.dim);
      while(!fd.isEmpty(tx)){
  	tx = uniform(0, fd.dim);
      }
      try{
	fd.put(tx);
      }catch(OutOfFieldException e){
	exit(1);
      }catch(FullColumnException e){
	exit(1);
      }
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
      try{
	fd.unput();
      }catch(NoHistoryException e){
	exit(1);
      }
    }
    // writeln("Random playout done.");
    return result;
  }
  
  private double playout(Field fd, int depth, int num_all_playouts)
    out(result){
      assert(0 <= result);
    }
  body{
    assert(to!double(num_playout)/(fd.dim + 1) >= 1);
    if(depth > log(to!double(num_playout)/(fd.dim + 1)) / log(fd.dim)){
      // writeln("Get into random palyout.");
      return random_playout(fd, depth);
    }else{
      // 盤面ハッシュにまだ情報がなかったら追加する
      // writefln("hash %s", fd);
      if(fd !in st){
	// writeln("Add board information to st.");
	Place[int] valid_places;
	for(int i = 0; i < fd.dim; i++){
	  if(fd.isEmpty(i)){
	    valid_places[i] = Place(i);
	  }
	}
	st[fd] = valid_places;
      }
      // foreach(var; st[fd]){
      // 	writefln("var: %s", var);
      // }
      auto x = reduce!(max)(st[fd]).x;
      // writefln("Chose %s.", x);
      assert(fd in st);

      int next_num_all_playouts = st[fd][x].n;
      try{
	fd.put(x);
      }catch(OutOfFieldException e){
	exit(1);
      }catch(FullColumnException e){
	exit(1);
      }

      double result;
      if(fd.isWin(x)){
	auto my_turn = (depth % 2 == 1 ? fd.turn : fd.reverseTurn());
  	if(my_turn == fd.reverseTurn()){
  	  result = WIN_REWARD;
  	}else{
  	  result = LOSE_REWARD;
  	}
      }else if(fd.isFull()){
	result = DRAW_REWARD;
      }else{
	depth++;
	result = playout(fd, depth, next_num_all_playouts);
      }
      try{
	fd.unput();
      }catch(NoHistoryException e){
	exit(1);
      }
      assert(fd in st);
      with(st[fd][x]){
	n++;
	reward += result;      
      }
      foreach(ref var; st[fd]){
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

    // writeln("All playout done.");

    Decision dec;
    dec.valid_places = st[fd];
    dec.x = reduce!(max)(dec.valid_places).x;    

    st.clear();
    return dec;
  }

  unittest{
    AI ai1 = new AI(1000);
    AI ai2 = new AI(1000);
    int[Field] hash;    
    Field fd = Field(6);
    fd.put(3);
    hash[fd] = 100;
    fd.put(4);
    hash[fd] = 200;
    fd.put(4);
    fd.put(0);
    fd.put(3);
    fd.unput();
    fd.unput();
    fd.unput();
    assert(fd in hash);        
    fd.unput();
    assert(fd in hash);        
  }
}
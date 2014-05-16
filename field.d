import std.stdio, std.c.stdlib, std.algorithm;

enum{BLANK, RED, YELLOW};

struct Field
{
  private byte[] field_body;
  private int m_dim;
  private byte m_turn;
  private immutable int NUM_MOKU;
  
  this(int m_dim)
  {
    this.m_dim = m_dim;
    field_body.length = m_dim^^2;
    m_turn = RED;
    NUM_MOKU = 4;    
  }

  this(this)
  {
    this.field_body = field_body.dup;
  }

  private byte get(int x, int y){
    return field_body[x + m_dim * y];
  }

  private void set(int x, int y, byte var){
    field_body[x + m_dim * y] = var;
  }  

  @property int dim(){return m_dim;}
  @property int turn(){return m_turn;}

  void setDim(int m_dim){
    this.m_dim = m_dim;
    field_body.length = this.m_dim^^2;
    clear();
  }

  byte reverseTurn()
  {
    return m_turn == RED ? YELLOW : RED;
  }
  
  void show()
  {
    for(int i = 0; i < m_dim; i++){
      writef(" %s", i);
    }
    writeln("");
    for(int i; i < m_dim; i++){
      write("|");
      for(int j; j < m_dim; j++){
	switch(get(j, i)){
	case BLANK:
	  write(" |");
	  break;
	case RED:
	  write("r|");
	  break;
	case YELLOW:
	  write("y|");
	  break;
	default:
	  writeln("Unknown value is included in the field.");
	  exit(1);
	  break;
	}
      }
      writeln("");
    }
    writeln("");
  }

  void clear()
  {
    foreach(ref byte var; field_body){
      var = 0;
    }
    m_turn = RED;
  }
  
  bool put(int x)
  {
    if(x < 0 || m_dim <= x){
      writefln("Input position %s is out of range.", x);
      return false;
    }

    // if(m_turn != RED && m_turn != YELLOW){
    //   writefln("Illegal value %s.", turn);
    //   return false;
    // }        
    
    if(get(x, 0) != BLANK){
      writefln("%s-th colum is already full.", x);
      return false;
    }
        

    for(int i = m_dim - 1; i >= 0; i--){
      if(get(x, i) == BLANK){
	set(x, i, m_turn);
	break;
      }
    }
    m_turn = reverseTurn();
    return true;
  }

  bool isWin(int x)
  {
    if(x < 0 || m_dim <= x){
      writeln("Input position is out of range.");
      return false;
    }
    
    byte y = 0;
    while(y < m_dim && get(x, y) == BLANK){
      y++;
    }
    if(m_dim <= y){
      return false;
    }

    byte turn = get(x, y);
    
    // 列のチェック
    bool inCheck = false;
    int count = 0;
    for(int i = 0; i < m_dim; i++){
      if(!inCheck && get(x, i) == turn){
	inCheck = true;
	count++;
      }else if(inCheck && get(x, i) != turn){
	if(count == NUM_MOKU) return true;
	inCheck = false;
	count = 0;
      }else if(inCheck && get(x, i) == turn){
	count++;	
      }
    }
    if(count == NUM_MOKU){
      return true;
    }
    
    // 行のチェック
    inCheck = false;
    count = 0;
    for(int i = 0; i < m_dim; i++){
      if(!inCheck && get(i, y) == turn){
    	inCheck = true;
    	count++;
      }else if(inCheck && get(i, y) != turn){
    	if(count == NUM_MOKU) return true;
    	inCheck = false;
    	count = 0;
      }else if(inCheck && get(i, y) == turn){
    	count++;
      }
    }
    if(count == NUM_MOKU){
      return true;
    }

    // 斜め（左上から右下）のチェック
    inCheck = false;
    count = 0;
    int offset = min(x, y);
    for(int i = 0; i < m_dim - abs(x - y); i++){
      if(!inCheck && get(x + i - offset, y + i - offset) == turn){
	inCheck = true;
	count++;
      }else if(inCheck && get(x + i - offset, y + i - offset) != turn){
	if(count == NUM_MOKU) return true;
	inCheck = false;
	count = 0;
      }else if(inCheck && get(x + i - offset, y + i - offset) == turn){
    	  count++;
      }
    }
    if(count == NUM_MOKU){
      return true;
    }

    // 斜め（左下から右上）のチェック
    inCheck = false;
    count = 0;
    offset = min(x, m_dim - y - 1);
    for(int i = 0; i < m_dim - abs(x - (dim - y - 1)); i++){
      if(!inCheck && get(x + i - offset, y - i + offset) == turn){
	inCheck = true;
	count++;
      }else if(inCheck && get(x + i - offset, y - i + offset) != turn){
	if(count == NUM_MOKU) return true;
	inCheck = false;
	count = 0;
      }else if(inCheck && get(x + i - offset, y - i + offset) == turn){
	count++;
      }
    }
    if(count == NUM_MOKU){
      return true;
    }
    
    return false;
  }

  bool isEmpty(int x)
  {
    if(get(x, 0) == BLANK) return true;
    else return false;
  }

  bool isFull()
  {
    for(int i = 0; i < dim; i++){
      if(isEmpty(i)){
	return false;
      }
    }
    return true;
  }

  unittest
  {
    // writeln("field unittest begin.");
    // Field fd = Field(5);
    // fd.show();
    // fd.put(0);
    // fd.show();
    // fd.put(0);
    // fd.show();
    // fd.put(0);
    // fd.show();
    // fd.put(0);
    // fd.show();
    // writeln("field unittest end.");
    // writeln("");
  }
}

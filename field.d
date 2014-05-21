import std.c.stdlib, std.algorithm, std.conv, std.container, std.random;
import std.stdio;

enum{BLANK, RED, YELLOW};

// 全体的にエラーチェックが行われていない
struct Field
{
  private byte[] field_body;
  private int m_dim;
  private byte m_turn;
  private immutable int NUM_MOKU;
  private int[] current_top;
  private SList!(int) history;
  
  this(int m_dim)
  {
    this.m_dim = m_dim;
    field_body.length = m_dim^^2;
    m_turn = RED;
    current_top.length = m_dim;
    current_top[] = m_dim;
    NUM_MOKU = 4;
  }

  hash_t toHash(){
    hash_t hash = 0;
    Random gen;
    for(int i = 0; i < m_dim; i++){
      for(int j = 0; j < m_dim; j++){
  	hash += get(i, j) * uniform(0, m_dim * m_dim * m_dim, gen);
      }
    }
    return hash;
    // return reduce!("a + b")(0, field_body);
  }

  bool opEquals(ref Field o)
  {
    return this.field_body[] == o.field_body[];
  }

  int opCmp(ref Field o)
  {
    return this.field_body[] >= o.field_body[];
  }

  // this(this)
  // {
  //   this.field_body = field_body.dup;
  // }

  // get, setのエラーチェック
  byte get(int x, int y){
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

  void clear()
  {
    foreach(ref byte var; field_body){
      var = 0;
    }    
    current_top[] = m_dim;
    history.clear();
    m_turn = RED;
  }

  bool unput()
  {
    if(history.empty()){
      writeln("No history exists.");
      return false;
    }
    
    set(history.front(), current_top[history.front()], BLANK);
    
    current_top[history.front()]++;
    history.removeFront();
    m_turn = reverseTurn();
    return true;
  }

  // 成功したら0, 失敗したらエラーコードを返すように変更しよう
  // それにともない、putを呼び出している箇所をすべて修正する必要がある
  bool put(int x)
  {
    if(x < 0 || m_dim <= x){
      writefln("Input position %s is out of range.", x);
      return false;
    }
    
    if(get(x, 0) != BLANK){
      writefln("%s-th colum is already full.", x);
      return false;
    }

    // current_topは実際に石が置かれている場所を指すので-1しなければならない
    set(x, current_top[x] - 1, m_turn);

    // for(int i = m_dim - 1; i >= 0; i--){
    //   if(get(x, i) == BLANK){
    // 	set(x, i, m_turn);
    // 	break;
    //   }
    // }
    
    current_top[x]--;
    history.insertFront(x);
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
    // Field fd = Field(6);
    // UI cui = new CUI();
    // fd.put(2);
    // cui.display(fd);
    // fd.put(3);
    // cui.display(fd);
    // fd.put(0);
    // cui.display(fd);
    // fd.unput();
    // cui.display(fd);
    // fd.unput();
    // cui.display(fd);
    // fd.put(0);
    // cui.display(fd);
    // fd.clear();
    // cui.display(fd);
    // fd.put(3);
    // cui.display(fd);
    // fd.put(3);
    // cui.display(fd);
    // fd.unput();
    // cui.display(fd);
    // fd.unput();
    // cui.display(fd);
    // fd.unput();
    // cui.display(fd);
    // fd.unput();
    // cui.display(fd);
  }
}

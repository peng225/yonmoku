import std.c.stdlib, std.algorithm, std.conv,
  std.container, std.random, std.exception;
import exception;

enum{BLANK, RED, YELLOW};

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

  bool opEquals(ref const Field o)
  {
    return this.field_body[] == o.field_body[];
  }

  int opCmp(ref const Field o)
  {
    return this.field_body[] >= o.field_body[];
  }

  byte get(int x, int y)
    in{
      assert(0 <= x && x < m_dim && 0 <= y && y < m_dim);
    }
  out(result){
    assert(result == RED || result == YELLOW
	   || result == BLANK);
  }
  body{
    return field_body[x + m_dim * y];
  }

  private void set(int x, int y, byte var)
    in{
      assert(0 <= x && x < m_dim);
      assert(0 <= y && y < m_dim);
      assert(var == RED || var == YELLOW || var == BLANK);
    }
  body{
    field_body[x + m_dim * y] = var;
  }  

  @property int dim(){return m_dim;}
  @property int turn(){return m_turn;}

  void setDim(int m_dim)
  {
    if(m_dim <= 0){
      throw new NonPositiveException("Non positive error",
				     m_dim);
    }
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

  void unput()
  {
    if(history.empty()){
      throw new NoHistoryException("History error");
    }
    
    set(history.front(), current_top[history.front()], BLANK);
    
    current_top[history.front()]++;
    history.removeFront();
    m_turn = reverseTurn();
  }

  void put(int x)
  {
    if(x < 0 || m_dim <= x){
      throw new OutOfFieldException("Invalid input", x);
      assert(false);
    }
    
    if(get(x, 0) != BLANK){
      throw new FullColumnException("Invalid input", x);
      assert(false);
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
  }

  bool isWin(int x)
    in{
      assert(0 <= x && x < m_dim);
    }
  body{    
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
    in{
      assert(0 <= x && x < m_dim);
    }
  body{
    if(get(x, 0) == BLANK) return true;
    else return false;
  }

  bool isFull()
  {
    for(int i = 0; i < m_dim; i++){
      if(isEmpty(i)){
	return false;
      }
    }
    return true;
  }

  unittest
  {
    Field fd = Field(6);
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

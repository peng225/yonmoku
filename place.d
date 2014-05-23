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
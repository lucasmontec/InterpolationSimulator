class Point{
  
  public int timestamp;
  public float x,y;
  
  public Point(){
    timestamp = 0;
    x = 0;
    y = 0;
  }
  
  public Point(int stamp, float px, float py){
    timestamp = stamp;
    x = px;
    y = py;
  }
}
class NoInterpolationInterpolator extends Interpolator{
  
  private float latestX, latestY;
  
  @Override
  public void Receive(Point p){
    latestX = p.x;
    latestY = p.y;
  }
  
  @Override
  public void Interpolate(int millis, Player p){
    p.position.x = latestX;
    p.position.y = latestY;
  }
  
}
class SimpleLinearInterpolator extends Interpolator{
  
  private float latestX, latestY;
  
  public float interpolationRate = 0.04f;
  
  @Override
  public void Receive(Point p){
    latestX = p.x;
    latestY = p.y;
  }
  
  @Override
  public void Interpolate(int millis, Player p){
    p.position.x = lerp(p.position.x, latestX, interpolationRate);
    p.position.y = lerp(p.position.y, latestY, interpolationRate);
  }
  
}
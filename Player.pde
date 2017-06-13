
class Player extends Host{
  public Point position;
  
  public float cx = 0f, cy = 0f;
  
  private float dx, dy;
  
  private final float radius = 100f;
  
  private float time = 0f;
  
  public Interpolator interpolator = new NoInterpolationInterpolator();
  
  public int randomTimeOffset;
  
  public Player(float sx, float sy, boolean isServer){
    super(isServer);
    position = new Point();
    position.x = sx;
    position.y = sy;
    cx = position.x;
    cy = position.y;
    
    //Simulate different time between client and server
    randomTimeOffset = (int)random(10,1500);
  }
  
  public void draw(){
    noFill();
    stroke(255);
    ellipse(cx,cy,radius*2,radius*2);
    
    if(isServer) fill(255,0,0);
    else fill(0,255,0);
    
    textAlign(CENTER, CENTER);
    textSize(20);
    text((isClient?"Client":"Server"), cx, cy);
    
    noStroke();
    ellipse(position.x + cx,position.y + cy,10,10);
  }
  
  public void move(){
    if(isServer){
      time = millis()*0.0015f;
      
      dx = - sin(time)*radius;
      dy = + cos(time)*radius;
      
      position.x = dx;
      position.y = dy;
      
      //New point made
      Point p = new Point(millis()+randomTimeOffset, dx,dy);
      Connection.sendToClients(p);
    }else{
      interpolator.Interpolate(millis(), this); 
    }
  }
  
  @Override
  protected void Receive(Object o){
    if(isClient){
      Point receive = (Point)o;
      if(receive != null){
        interpolator.Receive(receive);
      }
    }
  }
}
import java.util.*;

//Not working. It is bad.
class PWLinear2 extends Interpolator{
  
  private int lastMillis = 0;
  private int dt = 0;
  
  private class InterpEntry {
        public float timeReceived;
        public float timeSinceLast;
        public Point position;

        public InterpEntry(float timeReceived, float timeSinceLast, Point pos) {
            this.timeReceived = timeReceived;
            this.timeSinceLast = timeSinceLast;
            position = pos;
        }
  }
  
  // <summary>
  // How long to wait before starting interpolation
  // </summary>
  public float interpolationDelay = 40f;
  
  //Same as a queue (implements java queue)
  // All interpolation entries currently
  private LinkedList<InterpEntry> interpolationQueue = new LinkedList<InterpEntry>();
  
  // This is the current time relative to the current interpolation piece.
  private float currentTime = -1f;
  
  private Point latestPosition = new Point();
  
  private float latestStamp;
  private float oldestReceivedTime = 0f;
  float timeBetween;
  private InterpEntry current;
  float delta;

  @Override
  public void Receive(Point p){
    
    //Offer == Enqueue
    interpolationQueue.offer(new InterpEntry(millis(), p.timestamp - latestStamp, p));
    latestPosition.x = p.x;
    latestPosition.y = p.y;
    
    latestStamp = p.timestamp;
  }
  
  @Override
  public void Interpolate(int millis, Player target){
    dt = millis - lastMillis;
    
    //Delay the interpolation here, return oldest pos.
    if(interpolationQueue.size() > 0){
      oldestReceivedTime = interpolationQueue.peek().timeReceived;
    }
    if (millis - oldestReceivedTime < interpolationDelay) {
      currentTime = 0;
      return;
    }
    
    //Debug.Log(interpolationQueue.size()+"");
    
    //If we have elements, we need to start the interpolation
    if (interpolationQueue.size() > 0) {
      
      if(current == null || delta >= 1){
        currentTime = 0;
        current = interpolationQueue.poll();
        timeBetween = current.timeSinceLast;
        //Debug.Log("timeBetween "+timeBetween);
      }
  
      //Update time
      currentTime += dt;
      delta = currentTime/timeBetween;
      //Debug.Log("delta "+delta);

      //Snap
      if(timeBetween > 3*interpolationDelay){
        target.position = current.position;
        delta = 1;
      }else{
        //Return the interpolation of T0+dt in this piece
        target.position = lerp(target.position, current.position, delta);
      }
    }
    
    lastMillis = millis;
  }
  
}
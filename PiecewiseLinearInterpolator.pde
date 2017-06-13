import java.util.*;

//Lerp unclamped
public final float ulerp(float a, float b, float t) {
  return (1 - t) * a + t * b;
}

public final Point lerp(Point a, Point b, float t){
  Point ret = new Point();
  ret.x = ulerp(a.x, b.x, t);
  ret.y = ulerp(a.y, b.y, t);
  
  return ret;
}

class PiecewiseLinearInterpolator extends Interpolator{
  
  private int lastMillis = 0;
  private int dt = 0;
  
  private class InterpEntry {
        public float timestamp;
        public float timeReceived;
        public Point position;

        public InterpEntry(float timestamp, float timeReceived, Point pos) {
            this.timestamp = timestamp;
            this.timeReceived = timeReceived;
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


  @Override
  public void Receive(Point p){
    
    //Offer == Enqueue
    interpolationQueue.offer(new InterpEntry(p.timestamp, millis(), p));
    latestPosition.x = p.x;
    latestPosition.y = p.y;
    
    latestStamp = p.timestamp;
    //UpdateCurrentTime(timestamp);
  }
  
  @Override
  public void Interpolate(int millis, Player target){
    dt = millis - lastMillis;
    
    //Delay the interpolation here, return oldest pos.
    if(interpolationQueue.size() > 0){
      oldestReceivedTime = interpolationQueue.peek().timeReceived;
    }
    if (millis - oldestReceivedTime < interpolationDelay && interpolationQueue.size() < 2) {
      //Reset current time
      currentTime = -1f;
      return;
    }
    
    //Debug.Log(interpolationQueue.size()+"");
    
    //If we have elements, we need to start the interpolation
    if (interpolationQueue.size() > 0) {
      //This is E(n-1)
      InterpEntry prev = null;
  
      //If we don't have a time set, set the time to the oldest interp entry
      //The oldest entry is the first in the queue.
      if (currentTime < 0f) {
        prev = interpolationQueue.peek();//Same as dequeue
        currentTime = prev.timestamp - interpolationDelay;
      } else {
        //If we had time, we need to move forward by adding the delta time
        //From the last frame.
        currentTime += dt;
      }
  
      /*
      * Here we know where we are.
      * The time is:
      *
      * T0           T0+dt <- currentTime
      * |-------------|========
      *
      * where T0 is the oldest entry in the queue.
      * Now we need to find the current two entries
      * that we need to interpolate to.
      * This is done by finding the first entry where
      * T0+dt is smaller the the timestamp.
      *
      * Entry(n-1)        T0+dt      Entry(n)
      * |-----------------=|=--------|-----------
      *
      * Then we just need to interpolate pos to from E(n-1) to E(n).
      */
  
      //Boundaries
      if (currentTime > latestStamp) { 
        //Extrapolate if here
        //Debug.Log("currentTime > latestStamp currentTime: " + currentTime+" latestStamp: " + latestStamp+" Lerp ratio: "+(currentTime/latestStamp));
        //Debug.Log("dt: " + dt);
  
        //Set to latest position
        target.position = lerp(target.position, latestPosition, currentTime/latestStamp);
        
        //Dump queue and update time
        currentTime = -1;
        interpolationQueue.clear();
        
        return;
      }
  
      //This is E(n)
      InterpEntry next = interpolationQueue.poll();
      
      //Find the first entry where the current time doesn't pass it.
      while (currentTime > next.timestamp && interpolationQueue.size() > 0) {
        //Debug.Log("Current time > next.timeStamp");
        prev = next;
        next = interpolationQueue.poll();
      }
  
      //Current position is towards the first element of the queue
      //This means, since the first frame, the interpolation is still towards the first entry
      if (prev == null) {
        //Debug.Log("Prev = null");
        //Debug.Log("Interp to first in the list! nextStamp: " + next.timestamp + " currentTime: " + currentTime);
        //Debug.Log("delta time: " + dt);
        target.position = lerp(target.position, next.position, currentTime/next.timestamp);
        return;
      }
  
      //Calculate the time between points
      float timeBetween = next.timestamp - prev.timestamp;
      //Calculate T0+dt since prev instead of since begining
      float timeSincePrev = currentTime - prev.timestamp;
  
      //If there is no time, return next
      if (timeBetween == 0) {
        //Debug.Log("timebetween = 0 Time failed!");
        //Debug.Log("Time failed! nextStamp: " + next.timestamp + " prevstamp: " + prev.timestamp);
        //Debug.Log("currentTime: " + currentTime + " timeSincePrev: " + timeSincePrev);
        target.position = lerp(target.position, next.position, currentTime/next.timestamp);
        currentTime = -1;
        //if (DEBUG) {
        //    Draw.Target(next.position, Color.cyan, 0.5f, 2f);
        //}
  
        return;
      }
  
      //Return the interpolation of T0+dt in this piece
      target.position = lerp(prev.position, next.position, (timeSincePrev / timeBetween));
    } else {
      //Reset current time
      currentTime = -1f;
  
      //target.position = lerp(target.position, latestPosition, 0.5f);
    }
    
    lastMillis = millis;
  }
  
}
static class Connection{
  
  public static LinkedList<Object> buffer = new LinkedList<Object>();
  public static Object traveling = null;
  
  public static ArrayList<Host> hosts = new ArrayList<Host>();
  
  private static int time = 0;
  private static int lastMillis = 0;
  private static int deltaTime = 0;
  
  public static float sendInterval = 20f;
  
  public static float jitter = 0f;
  private static float currentJitter = 0f;
  
  public static float packetLoss = 0;
  
  private static int transmitDelay = 2;
  private static int lastTransmit = 0;
  
  private static int travelDelay = 10;
  private static int lastReceive = 0;
  
  public static void registerHost(Host h){
    if(!hosts.contains(h)){
      hosts.add(h);
    }
  }
  
  public static void sendToClients(Object o){
    buffer.add(o);
  }
  
  //Millis is the processing millis function
  //Call this in draw
  public static void update(int millis){
    deltaTime = millis - lastMillis;
    time += deltaTime;
    
    currentJitter = ((float)Math.random())*jitter;
    
    if(time > sendInterval){
      time = 0; 
      
      //Packet loss
      if((float)Math.random() < packetLoss && packetLoss > 0) buffer.clear();
      
      //Limit send buffer
      while(buffer.size() > 10){
        buffer.poll();
      }
      
      //Transmit object
      if(buffer.size() > 0 && millis-lastTransmit > transmitDelay && traveling == null){
        traveling = buffer.poll();
        lastTransmit = millis;
      }
      
      //Travel object
      if(millis-lastReceive > travelDelay+currentJitter){
        lastReceive = millis;
        for(Host h : hosts){
          if(h.isClient){
             h.Receive(traveling);
          }
        }
        traveling = null;
      }
      
      //Clear the buffer
      //buffer.clear();
    }

    lastMillis = millis;
  }
  
}
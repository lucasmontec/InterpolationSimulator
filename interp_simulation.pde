Player server = new Player(200,200, true);
Player client = new Player(600,200, false);

/*
  CONTROLS
  r - Reset all values
  space - Stops server movement
  +/- - Increases/Decreases interpolationDelay
  Shift +/- - Increases/Decreases sendInterval
  Shift p - Decreases packet loss
  p - Increases packet loss
  i - Toggle interpolator
*/

boolean serverCanMove = true;

void setup(){
  size(800,400);
  background(0);
  
  Connection.sendInterval = 20;
  Connection.registerHost(client);
  
  //client.interpolator = new SimpleLinearInterpolator();
  client.interpolator = new PWLinear2();
}

void draw(){
  background(0);
  
  textAlign(LEFT, BASELINE);
  fill(0,200,0);
  textSize(14);
  PiecewiseLinearInterpolator interpolator = null;
  if(client.interpolator instanceof PiecewiseLinearInterpolator){
    interpolator = (PiecewiseLinearInterpolator)client.interpolator;
  }
  text("Send interval: "+Connection.sendInterval+"ms", 10, 25);
  text("Interpolation delay: "+(interpolator==null?0f:interpolator.interpolationDelay)+"ms", 10, 40);
  text("Jitter: "+Connection.jitter+"ms", 10, 55);
  text("Packet loss: "+((int)(Connection.packetLoss*100f))+"%", 10, 70);
  text("Interpolator: "+(interpolator==null?"No interpolation":"Piecewise linear"), 10, 85);
  
  client.draw();
  client.move();
  
  server.draw();
  if(serverCanMove){
    server.move();
  }
  
  Connection.update(millis());
}

void keyReleased(){
 serverCanMove = true; 
}

void keyPressed(KeyEvent event) {
  
  PiecewiseLinearInterpolator interpolator = null;
  if(client.interpolator instanceof PiecewiseLinearInterpolator){
    interpolator = (PiecewiseLinearInterpolator)client.interpolator;
  }
  
  serverCanMove = key != ' ';
  
  //Toggle interpolator
  if (key == 'i') {
    if(client.interpolator instanceof PiecewiseLinearInterpolator){
      client.interpolator = new NoInterpolationInterpolator();
    }else{
      client.interpolator = new PiecewiseLinearInterpolator();
    }
  }
  
  //Reset
  if (key == 'r') {
    Connection.sendInterval = 20;
    Connection.jitter = 0;
    Connection.packetLoss = 0;
    if(interpolator != null){
      interpolator.interpolationDelay = 40f;
    }
  }
  
  //Packet loss
  if (key == 'P') {
    Connection.packetLoss -= 0.01f;
    if(Connection.packetLoss < 0) Connection.packetLoss = 0;
  }
  if (key == 'p') {
    Connection.packetLoss += 0.01f;
  }
  
  //Jitter control
  if(key == CODED){
    if(keyCode == UP){
      Connection.jitter += 5;
    }
    if(keyCode == DOWN){
      Connection.jitter -= 5;
      if(Connection.jitter < 0) Connection.jitter = 0;
    }
  }
  
  //Delays control
  if (event.isShiftDown()) {
    //print("woot");
    if (key == '+') {
      Connection.sendInterval += 5f;
    }
    if (key == '-') {
      Connection.sendInterval -= 5f;
      if(Connection.sendInterval < 0) Connection.sendInterval = 0;
    }
    
  }else{
    
    if(interpolator != null){
      if (key == '+') {
        interpolator.interpolationDelay += 5f;
      }
      if (key == '-') {
        interpolator.interpolationDelay -= 5f;
        if(interpolator.interpolationDelay < 0) interpolator.interpolationDelay = 0;
      }
    }
    
  }
  
}
abstract class Host{
  public final boolean isServer;
  public final boolean isClient;
  
  public Host(){
    isClient = true; 
    isServer = false;
  }
  
  public Host(boolean isServer){
    isClient = !isServer; 
    this.isServer = isServer;
  }
  
  protected void Receive(Object o){}
}
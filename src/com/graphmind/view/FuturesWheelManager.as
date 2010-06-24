package com.graphmind.view
{
  import com.graphmind.TreeManager;

  public class FuturesWheelManager extends TreeManager
  {
    
    private static var _instance:FuturesWheelManager;
    
    public static function getInstance():FuturesWheelManager {
      if (_instance == null) {
        _instance = new FuturesWheelManager();
      }
      
      return _instance;
    }
    
    public function FuturesWheelManager():void {
      super();
    }
      
  }
}
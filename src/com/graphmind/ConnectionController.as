package com.graphmind {
  
  import com.graphmind.util.OSD;
  import com.kitten.events.ConnectionEvent;
  import com.kitten.network.Connection;
  
  import mx.collections.ArrayCollection;
  
  public class ConnectionController {
    
    public static var mainConnection:Connection;
    private static var _connections:ArrayCollection = new ArrayCollection();


    /**
    * Constructor.
    */
    public function ConnectionController() {}

  
    /**
    * Get all network connections.
    */
    public static function get connections():ArrayCollection {
      return _connections;
    }
    
    
    /**
    * Get all the working connections.
    */
    public static function get liveConnections():ArrayCollection {
      var lives:ArrayCollection = new ArrayCollection();
      for (var idx:* in _connections) {
        if ((_connections[idx] as Connection).isConnected) {
          lives.addItem(_connections[idx]);
        }
      }
      return lives;
    }
    
    
    /**
    * Add connection.
    * Checks if the connection is already added.
    */
    public static function addConnection(conn:Connection):void {
      // Check if the connection is already added.
      for (var idx:* in _connections) {
        if ((_connections[idx] as Connection).target == conn.target) {
          return;
        }
      }
      
      _connections.addItem(conn);
    }
    
    
    public static function defaultErrorHandler(event:ConnectionEvent):void {
      OSD.show(
        "Network error\n" +
        "Connection details:" + 
        "\n  ULR: " + event.connection + 
        "\n  Connected: " + event.connection.isConnected +
        "\nError details:\n  " + 
        event.origialResponse['code'] + "\n  " +
        event.origialResponse['description'] + "\n  " +
        event.origialResponse['details'] + "\n  " +
        event.origialResponse['level'] + "\n  " +
        event.origialResponse['line'], OSD.ERROR
      );
    }

  }
  
}

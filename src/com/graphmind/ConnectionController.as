package com.graphmind {
  
  import com.graphmind.util.OSD;
  import com.kitten.events.ConnectionIOErrorEvent;
  import com.kitten.events.ConnectionNetStatusEvent;
  import com.kitten.network.Connection;
  
  import mx.collections.ArrayCollection;
  
  public class ConnectionController {
    
    public  static var mainConnection:Connection;
    private static var _connections:ArrayCollection = new ArrayCollection();


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
    private static function addConnection(conn:Connection):void {
      // Check if the connection is already added.
      for (var idx:* in _connections) {
        if ((_connections[idx] as Connection).target == conn.target) {
          return;
        }
      }
      
      _connections.addItem(conn);
    }
    
    
    /**
    * Default error handler for bad response.
    */
    public static function defaultRequestErrorHandler(result:Object):void {
      OSD.show(
        "Network request error:\n" +
        "Error details:\n" + 
        "  Details: " + result['details'] + "\n  " + 
        "  Code: " + result['code'] + "\n  " +
        "  Description: " + result['description'] + "\n  " +
        "  Level: " + result['level'] + "\n  " +
        "  Line: " + result['line'],
      OSD.ERROR);
    }
    
    
    /**
    * Default error handler for an io error.
    */
    public static function defaultIOErrorHandler(event:ConnectionIOErrorEvent):void {
      OSD.show("Network io error: " + event.ioErrorEvent, OSD.ERROR);
    }
    
    
    /**
    * Default error handler for a bad net status.
    */
    public static function defaultNetStatusHandler(event:ConnectionNetStatusEvent):void {
      OSD.show(
        "Network status error." +
        "\n  Connection: " + event.connection.target +  
        "\n  Code: " + event.netStatusEvent.info.code +
        "\n  Description: " + event.netStatusEvent.info.description +
        "\n  Details: " + event.netStatusEvent.info.details +
        "\n  Level: " + event.netStatusEvent.info.level
      , OSD.ERROR);
    }
    
    
    /**
    * Connection factory.
    */
    public static function createConnection(target:String):Connection {
      var conn:Connection = new Connection(target);
      addConnection(conn);
      return conn;
    }

  }
  
}

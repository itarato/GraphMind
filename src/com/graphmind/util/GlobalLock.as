package com.graphmind.util {
  
  public class GlobalLock {
    
    private static var locks:Object = {};

    
    /**
    * Lock a site.
    */
    public static function lock(site:String):void {
      if (!locks.hasOwnProperty(site)) {
        locks[site] = 0;
      }
      locks[site]++;
    }
    
    
    /**
    * Unlock a site.
    */
    public static function unlock(site:String):void {
      if (!locks.hasOwnProperty(site)) {
        return;
      }
      
      if (locks[site] <= 0) {
        return;
      }
      
      locks[site]--;
    }     
    
    
    /**
    * Flush a lock.
    */
    public static function clearLock(site:String):void {
      locks[site] = 0;
    }
    
    
    /**
    * Ask if a site is locked.
    */
    public static function isLocked(site:String):Boolean {
      return locks.hasOwnProperty(site) && locks[site] > 0;
    }
    
    
    /**
    * Mass lock checking.
    */
    public static function areLocked(sites:Array):Boolean {
      for (var idx:* in sites) {
        if (!isLocked(sites[idx])) {
          return false;
        }
      }
      return true;
    }

  }
  
}

package com.graphmind.view {
  
  import com.graphmind.display.FuturesWheelNodeController;
  import com.graphmind.display.ICloud;
  import com.graphmind.display.ITreeItem;
  import com.graphmind.display.NodeController;
  import com.graphmind.util.Log;
  
  import flash.geom.Point;
  import flash.utils.clearTimeout;
  import flash.utils.setTimeout;
  
  import mx.collections.ArrayCollection;
  import mx.core.UIComponent;

  public class FuturesWheelDrawer extends TreeDrawer {
    
    private static var FUTURE_WHEEL_CIRCLE_SLICE_HEIGHT:int = 140;
    private static var FUTURE_WHEEL_ELLIPSE_MULTIPLIER:Number = 1;
    private var center:Point = new Point();
    protected var levelCache:Array = new Array();
    private var maxLevel:uint = 0;
    
    [Embed(source="assets/images/draganddropcircle.png")]
    public static var draganddropcircle:Class;
    
    public function FuturesWheelDrawer(target:UIComponent, cloudContainer:UIComponent, connectionContainer:UIComponent, arrowLinkContainer:UIComponent):void {
      //TODO: implement function
      super(target, cloudContainer, connectionContainer, arrowLinkContainer);
      _connectionDrawer = new FuturesWheelConnectionDrawer(connectionContainer);
    }
    
    public override function initGraphics():void {
      super.initGraphics();
      GraphMind.i.mindmapCanvas.desktop_wrapper.horizontalScrollPosition = (_target.width - GraphMind.i.mindmapCanvas.desktop_wrapper.width + 100) >> 1;
      
      GraphMind.i.mindmapCanvas.dragAndDrop_shape.source = FuturesWheelDrawer.draganddropcircle;
    }
    
    public override function refreshGraphics():void {
      if (_isLocked) return;
      
      clearTimeout(_timer);
      Log.debug('TreeDrawer.rerfreshGraphics()');
      _timer = setTimeout(function():void {
        
        _connectionDrawer.clearAll();
        _cloudDrawer.clearAll();
        _arrowLinkContainer.clearAll();
        
        // Refresh the whole tree.
        center.x = GraphMind.i.stageManager.rootNode.getUI().x = (_target.width >> 1);
        center.y = GraphMind.i.stageManager.rootNode.getUI().y = (_target.height >> 1);
        var postProcessObjects:Object = new Object();
        postProcessObjects.arrowLinks = new Array();
        
        countLevels(GraphMind.i.stageManager.rootNode);
        drawLevelCircle(GraphMind.i.mindmapCanvas.desktop_overlay, maxLevel - 1);
        
        _redrawFuturesWheenNode(GraphMind.i.stageManager.rootNode, postProcessObjects);
        
        _redrawArrowLinks(postProcessObjects.arrowLinks);
      }, 10);
    }
    
    protected function countLevels(node:ITreeItem, level:int = 1):void {
      if (level > maxLevel) maxLevel = level;
      
      if (!levelCache[level]) {
        levelCache[level] = 0;
      }
      levelCache[level]++;
      
      for each (var child:ITreeItem in node.getChildNodeAll()) {
        countLevels(child, level + 1);
      }
    }
    
    protected function _redrawFuturesWheenNode(node:ITreeItem, postProcessObjects:Object, circleLevel:int = 1, parentAngle:Number = 0, sliceAngle:Number = 360):Number {
      
      trace('Level: ' + circleLevel + ' Parent angle: ' + parentAngle + ' Slice: ' + sliceAngle);
      node.getUI().refreshGraphics();
      node.getUI().x -= node.getUI().getWidth() >> 1;
      node.getUI().y -= node.getUI().getHeight() >> 1;
      (node as NodeController).nodeView._backgroundComp.setStyle('borderColor', getLevelColor(circleLevel));
      
      // Walking through all the children.
      var childs:ArrayCollection = node.getChildNodeAll();
      var childNum:uint = childs.length; 
      for (var idx:* in childs) {
        var child:ITreeItem = node.getChildNodeAll()[idx];
        var subtreeWidth:int = _getSubtreeHeight(child);
        
        var angle:Number;
        angle = (parentAngle - sliceAngle / 2) + (sliceAngle / childNum) * idx + (sliceAngle / (childNum + 1));
        
        var p:Point = _angleTransformation(angle, FUTURE_WHEEL_CIRCLE_SLICE_HEIGHT * circleLevel);
        (child as FuturesWheelNodeController).angle = angle;
        child.getUI().x = p.x + center.x;
        child.getUI().y = p.y + center.y;
        _redrawFuturesWheenNode(child, postProcessObjects, circleLevel + 1, angle, sliceAngle / childNum);
        
        if (!node.isCollapsed()) {
          (_connectionDrawer as FuturesWheelConnectionDrawer).drawWithColor(node, child, getLevelColor(circleLevel));
        }
      }
      
      // Cloud.
      if (node is ICloud && (node as ICloud).hasCloud() && (!node.getParentNode() || !node.getParentNode().isCollapsed())) {
        _cloudDrawer.draw(node);
      }
      
      // ArrowLinks
      (postProcessObjects.arrowLinks as Array).push((node as NodeController).getArrowLinks());
      
      return 0;
    }
    
    private function _angleTransformation(angle:Number, length:Number):Point {
      var p:Point = new Point();
      
      if (angle == 0) {
        p.y = length;
        return p;
      }
  
      p.x = Math.sin(Math.PI / (180.0 / angle)) * length * FUTURE_WHEEL_ELLIPSE_MULTIPLIER;
      p.y = Math.cos(Math.PI / (180.0 / angle)) * length;
  
      return p;
    }
    
    public static function getLevelColor(level:int):uint {
      switch (level) {
        case 0:
        case 1: return 0x0000FF;
        case 2: return 0xFF0000;
        case 3: return 0x00FF00;
        case 4: return 0xFFFF00;
        case 5: return 0xFF00FF;
        case 6: return 0x00FFFF;
        default: return 0x000000;
      }
    }
    
    private function drawLevelCircle(target:UIComponent, level:int):void {
      var thickness:uint = 3;

      target.graphics.clear();
      for (var i:int = level; i >= 1; i--) {      
        target.graphics.beginFill(getLevelColor(i + 1));
        target.graphics.drawCircle(center.x, center.y, i * FUTURE_WHEEL_CIRCLE_SLICE_HEIGHT);
        target.graphics.endFill();
        target.graphics.beginFill(0xFFFFFF);
        target.graphics.drawCircle(center.x, center.y, i * FUTURE_WHEEL_CIRCLE_SLICE_HEIGHT - thickness);
        target.graphics.endFill();
      }
    }
    
  }
  
}
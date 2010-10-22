package com.graphmind.display {
  import com.graphmind.data.NodeData;
  import com.graphmind.util.Log;
  import com.graphmind.view.FuturesWheelNodeUI;
  import com.graphmind.view.NodeUI;
  
  import flash.events.MouseEvent;
  import flash.filters.GlowFilter;
  
  
  public class FuturesWheelNodeController extends NodeController {
    
    private static var _nodeGlowFilter1:GlowFilter = new GlowFilter(0x6688AA, 1, 8, 8, 10, 1);
    private static var _nodeGlowFilter2:GlowFilter = new GlowFilter(0xFFFFFF, 1, 5, 5, 10, 1);
    
    public var angle:Number = 0;
   
    // @TODO make it safe
    private static var arrowLinkConnFirst:FuturesWheelNodeController;
    
    public function FuturesWheelNodeController(nodeData:NodeData, newNodeView:NodeUI = null):void {
      //TODO: implement function
      super(nodeData, newNodeView);
      
      (nodeView as FuturesWheelNodeUI).arrowLinkIcon.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown_arrowLinkIcon);
    }
    
    public override function _setBackgroundEffect(effect:int = EFFECT_NORMAL):void {
      nodeView._backgroundComp.filters = (effect == EFFECT_NORMAL) ? [] : [_nodeGlowFilter2, _nodeGlowFilter1];
    }
    
    public override function onMouseDown(event:MouseEvent):void {
      if (!GraphMind.i.applicationManager.isEditable()) return;

      if (this != GraphMind.i.stageManager.rootNode) {
        GraphMind.i.stageManager.prepaireDragAndDrop();
        dragAndDrop_sourceNode = this;
      }
      
      event.stopImmediatePropagation();
    }
    
    public override function onMouseUp(event:MouseEvent):void {
      if ((!NodeController.isPrepairedNodeDragAndDrop) && NodeController.isNodeDragAndDrop) {
        finishDragAndDrop();
      }
      
      if (arrowLinkConnFirst) {
        finishArrowLinkCreation();
      }
      
      arrowLinkConnFirst = null;
      GraphMind.i.stageManager.closeNodeDragAndDrop();
    }
    
    public override function onMouseMove(event:MouseEvent):void {
//      if ((!NodeController.isPrepairedNodeDragAndDrop) && NodeController.isNodeDragAndDrop) {
//        var vangle:Number = (Math.atan2(nodeView.mouseY - (nodeView.getHeight() >> 1), 
//                                      nodeView.mouseX - (nodeView.getWidth() >> 1)) * (180.0 / Math.PI) - 90);
//        vangle += angle - 180;
//        GraphMind.i.mindmapCanvas.dragAndDrop_shape.rotation = vangle;
//      }
    }
    
    public override function onMouseOver(event:MouseEvent):void {
      super.onMouseOver(event);
      (nodeView as FuturesWheelNodeUI).arrowLinkIcon.visible = GraphMind.i.applicationManager.isEditable();
    }
    
    public override function onMouseOut(event:MouseEvent):void {
      super.onMouseOut(event);
      (nodeView as FuturesWheelNodeUI).arrowLinkIcon.visible = false;
    }
    
    protected function onMouseDown_arrowLinkIcon(event:MouseEvent):void {
      if (!GraphMind.i.applicationManager.isEditable()) return;
      
      arrowLinkConnFirst = this;
      
      event.stopImmediatePropagation();
    }
    
    protected function finishDragAndDrop():void {
      var vangle:Number;
      if (this == GraphMind.i.stageManager.rootNode) {
        // Root node only has child.
        vangle = 180;
      } else {
        vangle = (Math.atan2(nodeView.mouseY - (nodeView.getHeight() >> 1), 
                                    nodeView.mouseX - (nodeView.getWidth() >> 1)) * (180.0 / Math.PI) - 90);
        vangle += angle - 180;
        while (vangle < 0) vangle += 360;
      }
      
      if (vangle < 120) {
        // Left
        trace('Left');
        NodeController.moveToPrevSibling(dragAndDrop_sourceNode, this);
      } else if (vangle < 240) {
        // Child
        trace('Child');
        NodeController.move(dragAndDrop_sourceNode, this);
      } else {
        // Right
        trace('Right');
        NodeController.moveToNextSibling(dragAndDrop_sourceNode, this);
      }
    }
    
    protected function finishArrowLinkCreation():void {
      if (arrowLinkConnFirst == this) return;
      
      var tal:TreeArrowLink = new TreeArrowLink(arrowLinkConnFirst, nodeData.id);
      tal.findTargetNode();
      
      arrowLinkConnFirst = null;
      
      update(UP_TIME | UP_TREE_UI);
    }
    
    public override function removeArrowLink(arrowLink:TreeArrowLink):void {
      try {
        _arrowLinks.removeItemAt(_arrowLinks.getItemIndex(arrowLink));
        TreeArrowLink.arrowLinks.removeItemAt(TreeArrowLink.arrowLinks.getItemIndex(arrowLink));
        arrowLink.parent.removeChild(arrowLink);
      } catch (e:Error) {
        Log.error('Link removal is failed.');
      }
    }
    
    public override function toString():String {
      return '[FuturesWheelNodeController: ' + this.nodeData.id + ' - ' + getUI().x + ',' + getUI().y + ']';
    }
    
  }
  
}
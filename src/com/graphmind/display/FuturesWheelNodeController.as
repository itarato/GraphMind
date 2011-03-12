package com.graphmind.display {
  
  import com.graphmind.ApplicationController;
  import com.graphmind.TreeMapViewController;
  import com.graphmind.data.NodeData;
  import com.graphmind.util.Log;
  import com.graphmind.view.FuturesWheelNodeView;
  import com.graphmind.view.NodeView;
  
  import flash.events.MouseEvent;
  import flash.filters.GlowFilter;
  
  
  public class FuturesWheelNodeViewController extends NodeViewController {
    
    private static var _nodeGlowFilter1:GlowFilter = new GlowFilter(0x6688AA, 1, 8, 8, 10, 1);
    private static var _nodeGlowFilter2:GlowFilter = new GlowFilter(0xFFFFFF, 1, 5, 5, 10, 1);
    
    public var angle:Number = 0;
   
    // @TODO make it safe
    private static var arrowLinkConnFirst:FuturesWheelNodeViewController;
    
    public function FuturesWheelNodeViewController(nodeData:NodeData, newNodeView:NodeView = null):void {
      //TODO: implement function
      super(nodeData, newNodeView);
      
      (view as FuturesWheelNodeView).arrowLinkIcon.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown_arrowLinkIcon);
    }
    
    public override function _setBackgroundEffect(effect:int = EFFECT_NORMAL):void {
      view._backgroundComp.filters = (effect == EFFECT_NORMAL) ? [] : [_nodeGlowFilter2, _nodeGlowFilter1];
    }
    
    public override function onMouseDown(event:MouseEvent):void {
      if (!ApplicationController.i.isEditable()) return;

      if (this != TreeMapViewController.i.rootNode) {
        TreeMapViewController.i.prepaireDragAndDrop();
        dragAndDrop_sourceNode = this;
      }
      
      event.stopImmediatePropagation();
    }
    
    public override function onMouseUp(event:MouseEvent):void {
      if ((!NodeViewController.isPrepairedNodeDragAndDrop) && NodeViewController.isNodeDragAndDrop) {
        finishDragAndDrop();
      }
      
      if (arrowLinkConnFirst) {
        finishArrowLinkCreation();
      }
      
      arrowLinkConnFirst = null;
      TreeMapViewController.i.closeNodeDragAndDrop();
    }
    
    public override function onMouseMove(event:MouseEvent):void {
//      if ((!NodeViewController.isPrepairedNodeDragAndDrop) && NodeViewController.isNodeDragAndDrop) {
//        var vangle:Number = (Math.atan2(nodeView.mouseY - (nodeView.getHeight() >> 1), 
//                                      nodeView.mouseX - (nodeView.getWidth() >> 1)) * (180.0 / Math.PI) - 90);
//        vangle += angle - 180;
//        GraphMind.i.mindmapCanvas.dragAndDrop_shape.rotation = vangle;
//      }
    }
    
    public override function onMouseOver(event:MouseEvent):void {
      super.onMouseOver(event);
      (view as FuturesWheelNodeView).arrowLinkIcon.visible = ApplicationController.i.isEditable();
    }
    
    public override function onMouseOut(event:MouseEvent):void {
      super.onMouseOut(event);
      (view as FuturesWheelNodeView).arrowLinkIcon.visible = false;
    }
    
    protected function onMouseDown_arrowLinkIcon(event:MouseEvent):void {
      if (!ApplicationController.i.isEditable()) return;
      
      arrowLinkConnFirst = this;
      
      event.stopImmediatePropagation();
    }
    
    protected function finishDragAndDrop():void {
      var vangle:Number;
      if (this == TreeMapViewController.i.rootNode) {
        // Root node only has child.
        vangle = 180;
      } else {
        vangle = (Math.atan2(view.mouseY - (view.getHeight() >> 1), 
                                    view.mouseX - (view.getWidth() >> 1)) * (180.0 / Math.PI) - 90);
        vangle += angle - 180;
        while (vangle < 0) vangle += 360;
      }
      
      if (vangle < 120) {
        // Left
        trace('Left');
        NodeViewController.moveToPrevSibling(dragAndDrop_sourceNode, this);
      } else if (vangle < 240) {
        // Child
        trace('Child');
        NodeViewController.move(dragAndDrop_sourceNode, this);
      } else {
        // Right
        trace('Right');
        NodeViewController.moveToNextSibling(dragAndDrop_sourceNode, this);
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
      return '[FuturesWheelNodeViewController: ' + this.nodeData.id + ' - ' + getUI().x + ',' + getUI().y + ']';
    }
    
  }
  
}

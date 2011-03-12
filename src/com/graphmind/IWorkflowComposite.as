package com.graphmind {
  
  import com.graphmind.view.NodeView;
  import com.graphmind.view.TreeArrowLinkDrawer;
  
  import mx.core.UIComponent;
  
  public interface IWorkflowComposite {
    
    function createNodeView():NodeView;
    
    function createStageManager():TreeMapViewController;
    
    function getNodeViewControllerClass():Class;
    
    function createArrowLinkDrawer(target:UIComponent):TreeArrowLinkDrawer;
    
  }
  
}

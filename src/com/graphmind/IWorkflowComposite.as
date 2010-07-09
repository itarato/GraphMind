package com.graphmind {
  
  import com.graphmind.view.NodeUI;
  import com.graphmind.view.TreeArrowLinkUI;
  
  import mx.core.UIComponent;
  
  public interface IWorkflowComposite {
    
    function createNodeUI():NodeUI;
    
    function createStageManager():StageManager;
    
    function getNodeControllerClass():Class;
    
    function createArrowLinkDrawer(target:UIComponent):TreeArrowLinkUI;
    
  }
  
}
package com.graphmind
{
  import com.graphmind.display.NodeController;
  import com.graphmind.view.NodeUI;
  import com.graphmind.view.TreeArrowLinkUI;
  import com.graphmind.view.TreeDrawer;
  
  import mx.core.UIComponent;

  public class TreeWorkflow implements IWorkflowComposite
  {
    public function TreeWorkflow():void {
    }

    public function createNodeUI():NodeUI {
      return new NodeUI();
    }
    
    public function createStageManager():MapController {
      return new MapController(
        new TreeDrawer(
          GraphMind.i.mindmapCanvas.desktop,
          GraphMind.i.mindmapCanvas.desktop_cloud,
          GraphMind.i.mindmapCanvas.desktop,
          GraphMind.i.mindmapCanvas.desktop_overlay
        )
      );
    }
    
    public function getNodeControllerClass():Class {
      return NodeController;
    }
    
    public function createArrowLinkDrawer(target:UIComponent):TreeArrowLinkUI {
      return new TreeArrowLinkUI(target);
    }
    
  }
}
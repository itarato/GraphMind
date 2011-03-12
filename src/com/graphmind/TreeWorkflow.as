package com.graphmind
{
  import com.graphmind.display.NodeViewController;
  import com.graphmind.view.NodeView;
  import com.graphmind.view.TreeArrowLinkDrawer;
  import com.graphmind.view.TreeDrawer;
  
  import mx.core.UIComponent;

  public class TreeWorkflow implements IWorkflowComposite
  {
    public function TreeWorkflow():void {
    }

    public function createNodeView():NodeView {
      return new NodeView();
    }
    
    public function createStageManager():TreeMapViewController {
      return new TreeMapViewController(
        new TreeDrawer(
          GraphMind.i.mindmapCanvas.desktop,
          GraphMind.i.mindmapCanvas.desktop_cloud,
          GraphMind.i.mindmapCanvas.desktop,
          GraphMind.i.mindmapCanvas.desktop_overlay
        )
      );
    }
    
    public function getNodeViewControllerClass():Class {
      return NodeViewController;
    }
    
    public function createArrowLinkDrawer(target:UIComponent):TreeArrowLinkDrawer {
      return new TreeArrowLinkDrawer(target);
    }
    
  }
}

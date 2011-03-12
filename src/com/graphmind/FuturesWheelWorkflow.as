package com.graphmind {
  
  import com.graphmind.display.FuturesWheelNodeViewController;
  import com.graphmind.view.FuturesWheelArrowLinkUI;
  import com.graphmind.view.FuturesWheelDrawer;
  import com.graphmind.view.FuturesWheelNodeView;
  import com.graphmind.view.NodeView;
  import com.graphmind.view.TreeArrowLinkDrawer;
  
  import mx.core.UIComponent;

  public class FuturesWheelWorkflow implements IWorkflowComposite {
    public function FuturesWheelWorkflow() {
    }

    public function createNodeView():NodeView {
      return new FuturesWheelNodeView();
    }
    
    public function createStageManager():TreeMapViewController {
      return new TreeMapViewController(
        new FuturesWheelDrawer(
          GraphMind.i.mindmapCanvas.desktop,
          GraphMind.i.mindmapCanvas.desktop_cloud,
          GraphMind.i.mindmapCanvas.desktop,
          GraphMind.i.mindmapCanvas.desktop_arrowlink
        )
      );
    }
    
    public function getNodeViewControllerClass():Class {
      return FuturesWheelNodeViewController;
    }
    
    public function createArrowLinkDrawer(target:UIComponent):TreeArrowLinkDrawer {
      return new FuturesWheelArrowLinkUI(target);
    }
    
  }

}

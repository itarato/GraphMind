package com.graphmind {
  
  import com.graphmind.display.FuturesWheelNodeController;
  import com.graphmind.view.FuturesWheelArrowLinkUI;
  import com.graphmind.view.FuturesWheelDrawer;
  import com.graphmind.view.FuturesWheelNodeUI;
  import com.graphmind.view.NodeUI;
  import com.graphmind.view.TreeArrowLinkUI;
  
  import mx.core.UIComponent;

  public class FuturesWheelWorkflow implements IWorkflowComposite {
    public function FuturesWheelWorkflow() {
    }

    public function createNodeUI():NodeUI {
      return new FuturesWheelNodeUI();
    }
    
    public function createStageManager():MapController {
      return new MapController(
        new FuturesWheelDrawer(
          GraphMind.i.mindmapCanvas.desktop,
          GraphMind.i.mindmapCanvas.desktop_cloud,
          GraphMind.i.mindmapCanvas.desktop,
          GraphMind.i.mindmapCanvas.desktop_arrowlink
        )
      );
    }
    
    public function getNodeControllerClass():Class {
      return FuturesWheelNodeController;
    }
    
    public function createArrowLinkDrawer(target:UIComponent):TreeArrowLinkUI {
      return new FuturesWheelArrowLinkUI(target);
    }
    
  }

}
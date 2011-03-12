package com.graphmind {
  
  import com.graphmind.display.NodeViewController;
  import com.graphmind.event.EventCenter;
  import com.graphmind.event.EventCenterEvent;
  
  public class AppFormController {
                
    /**
     * Active node's attributes -> to display it as attributes.
     * Sensitive information not included (ie: passwords).
     */ 
    [Bindable]
    public var selectedNodeData:ArrayCollection = new ArrayCollection();
    
    
    /**
    * Consructor.
    */
    public function AppFormController() {
      EventCenter.i.subscribe(EventCenterEvent.NODE_SELECTED, onNodeSelected);
    }

    
    /**
    * Act when a node was got selected.
    */
    public function onNodeSelected(event:EventCenterEvent):void {
      var node:NodeViewController = event.data;
      
      for (var key:* in node.nodeData.data) {
        TreeMapViewController.i.selectedNodeData.addItem({
          key: key,
          value: nodeData.data[key]
        });
      }     
      
      GraphMind.i.mindmapToolsPanel.node_info_panel.nodeLabelRTE.htmlText = nodeView._displayComp.title_label.htmlText || nodeView._displayComp.title_label.text;
        
      if (!isTheSameSelected) {
        GraphMind.i.mindmapToolsPanel.node_info_panel.link.text = nodeData.link;
        GraphMind.i.mindmapToolsPanel.node_attributes_panel.attributes_update_param.text = '';
        GraphMind.i.mindmapToolsPanel.node_attributes_panel.attributes_update_value.text = '';
      }
    }

  }
  
}

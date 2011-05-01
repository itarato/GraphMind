package com.graphmind {
	
	import com.graphmind.data.DrupalViews;
	import com.graphmind.data.DrupalViewsQuery;
	import com.graphmind.data.NodeDataObject;
	import com.graphmind.data.NodeType;
	import com.graphmind.display.ConfigPanelController;
	import com.graphmind.display.ICloud;
	import com.graphmind.display.ITreeNode;
	import com.graphmind.display.TreeArrowLink;
	import com.graphmind.event.EventCenter;
	import com.graphmind.event.EventCenterEvent;
	import com.graphmind.event.NodeEvent;
	import com.graphmind.temp.DrupalItemRequestParamObject;
	import com.graphmind.temp.DrupalViewsRequestParamObject;
	import com.graphmind.util.OSD;
	import com.graphmind.util.ObjectUtil;
	import com.graphmind.util.StringUtility;
	import com.graphmind.view.NodeActionIcon;
	import com.graphmind.view.NodeView;
	import com.kitten.network.Connection;
	
	import components.DrupalItemLoadPanel;
	import components.NodeAttributes;
	import components.NodeIcons;
	import components.NodeInfo;
	import components.ViewLoadPanel;
	
	import flash.events.ContextMenuEvent;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	import mx.core.BitmapAsset;
	import mx.events.FlexEvent;

  [Event(name="updateData",           type="com.graphmind.event.NodeEvent")]
  [Event(name="updateGraphics",       type="com.graphmind.event.NodeEvent")]
  [Event(name="moved",                type="com.graphmind.event.NodeEvent")]
  [Event(name="deleted",              type="com.graphmind.event.NodeEvent")]
  [Event(name="created",              type="com.graphmind.event.NodeEvent")]
  [Event(name="attributeChanged",     type="com.graphmind.event.NodeEvent")]
  [Event(name="dragAndDropFinished",  type="com.graphmind.event.NodeEvent")]
  [Event(type="com.graphmind.event.NodeEvent", name="click")]
  [Event(type="com.graphmind.event.NodeEvent", name="mouseOver")]
  [Event(type="com.graphmind.event.NodeEvent", name="mouseOut")]
  [Event(type="com.graphmind.event.NodeEvent", name="doubleClick")]
  [Event(type="com.graphmind.event.NodeEvent", name="keyUpTitleTextField")]
  [Event(type="com.graphmind.event.NodeEvent", name="focusOutTitleTextField")]
  [Event(type="com.graphmind.event.NodeEvent", name="itemLoaderSelectorClick")]
  [Event(type="com.graphmind.event.NodeEvent", name="clickAddSimpleNode")]
  [Event(type="com.graphmind.event.NodeEvent", name="clickAddDrupalItem")]
  [Event(type="com.graphmind.event.NodeEvent", name="clickAddDrupalViews")]
  [Event(type="com.graphmind.event.NodeEvent", name="clickNodeLink")]
  [Event(type="com.graphmind.event.NodeEvent", name="mouseDown")]
  [Event(type="com.graphmind.event.NodeEvent", name="mouseUp")]
  [Event(type="com.graphmind.event.NodeEvent", name="mouseMove")]
  [Event(type="com.graphmind.event.NodeEvent", name="contextMenuAddSimpleNode")]
  [Event(type="com.graphmind.event.NodeEvent", name="contextMenuAddDrupalItem")]
  [Event(type="com.graphmind.event.NodeEvent", name="contextMenuAddDrupalViews")]
  [Event(type="com.graphmind.event.NodeEvent", name="contextMenuRemoveNode")]
  [Event(type="com.graphmind.event.NodeEvent", name="contextMenuRemoveChilds")]
	public class NodeViewController extends EventDispatcher implements ITreeNode, ICloud {
		
		// Node access caches
		public static var nodes:ArrayCollection = new ArrayCollection();
		
		// Updated node ui
		public static const UP_UI:uint = 1;
		
		// Time delay until selecting a node on mouseover
		protected var _mouseSelectionTimeout:uint;

    // Drag and drop info.    
    public static var dragAndDrop_sourceNode:NodeViewController;
    public static var isNodeDragAndDrop:Boolean = false;
    public static var isPrepairedNodeDragAndDrop:Boolean = false;

    /**
     * Various background effects.
     */
    public static var _nodeGlowFilter:GlowFilter = new GlowFilter(0x0089FF, 1, 4, 4, 8);
    public static var _nodeInnerGlowFilter:GlowFilter = new GlowFilter(0xFFFFFF, 1, 3, 3, 3, 2, true);
    public static var _nodeInnerGlowFilter2:GlowFilter = new GlowFilter(0xFFFFFF, .5, 20, 20, 3, 2, true);
    
    /**
     * Related names of background effects.
     */
    public static const EFFECT_NORMAL:int = 0;
    public static const EFFECT_HIGHLIGHT:int = 1;
    
    /**
     * Model.
     */
    public var nodeData:NodeDataObject;
    
    /**
     * View.
     */
    public var view:NodeView;
    
    /**
     * Child nodes.
     */
    protected var _children:ArrayCollection = new ArrayCollection();
        
    /**
     * Subtree is collapsed.
     */
    protected var _isCollapsed:Boolean = false;
   
    /**
     * Collapsed directly - means not collapsed by folding a parent node.
     */
    protected var _isForcedCollapsed:Boolean = false;
    
    /**
     * Parent node.
     * For the root it's null.
     */
    public var parent:NodeViewController = null;
    
    /**
     * ArrowLinks
     */
    protected var _arrowLinks:ArrayCollection = new ArrayCollection();
    
    /**
    * Selection flag - true if the node is selected.
    */
    public var isSelected:Boolean = false;

    /**
    * Feature - if the node can has normal child nodes.
    */
    public static var CAN_HAS_NORMAL_CHILD:String = 'canHasNormalChild';    
    public var canHasNormalChild:Boolean = true;
    public static var canHasNormalChild:Boolean = true;
    
    /**
    * Feature - anchor.
    */
    public static var CAN_HAS_ANCHOR:String = 'canHasAnchor';
    public var canHasAnchor:Boolean = true;
    public static var canHasAnchor:Boolean = true;
    
    /**
    * Attributes.
    */
    public static var CAN_HAS_ATTRIBUTES:String = 'canHasAttributes';
    public static var canHasAttributes:Boolean = true;
    
    /**
    * Add action icon and the image source.
    */
    [Embed(source='assets/images/add.png')]
    public var image_add:Class;
    protected var addNodeIcon:NodeActionIcon;

    /**
    * Anchor icon and the image source.
    */    
    [Embed(source='assets/images/anchor.png')]
    public var image_anchor:Class;
    protected var drupalLinkIcon:NodeActionIcon;
    
    /**
    * Node configuration panel.
    */
    private static var nodeConfigPanel:ConfigPanelController;
    private static var nodeConfigComponent:NodeInfo;
    
    /**
    * Node attributes panel.
    */
    private static var nodeAttributesPanel:ConfigPanelController;
    private static var nodeAttributesComponent:NodeAttributes;
    
    /**
    * Node icons panel.
    */
    private static var nodeIconsPanel:ConfigPanelController;
    private static var nodeIconsComponent:NodeIcons;
    
    /**
    * Load Drupal item panel.
    */
    private static var loadDrupalItemPanel:ConfigPanelController;
    private static var loadDrupalItemComponent:DrupalItemLoadPanel;
 
    /**
    * Load Drupal Views list panel.
    */
    private static var loadDrupalViewsPanel:ConfigPanelController;
    private static var loadDrupalViewsComponent:ViewLoadPanel;
                       
    /**
     * Active node's attributes -> to display it as attributes.
     * Sensitive information not included (ie: passwords).
     */ 
    public static var selectedNodeData:ArrayCollection = new ArrayCollection();
        
    /**
     * Active node.
     */
    public static var activeNode:NodeViewController;
    

    /**
     * Constructor.
     */ 
		public function NodeViewController(_nodeData:NodeDataObject = null, features:Object = null) {
			super();

      // Simple node child feature
      if (
        ObjectUtil.isObjectAttributeFalse(features, CAN_HAS_NORMAL_CHILD) || 
        !NodeViewController.canHasNormalChild ||
        !FeatureController.isFeatureEnabled(FeatureController.CREATE_MINDMAP_NODE)
      ) {
        canHasNormalChild = false;        
      }
      
      // Anchor feature
      if (
        ObjectUtil.isObjectAttributeFalse(features, CAN_HAS_ANCHOR) ||
        !NodeViewController.canHasAnchor
      ) {
        canHasAnchor = false;
      }
  
      // Setting node data.			
			if (_nodeData == null) {
			  nodeData = new NodeDataObject();
			} else {
        nodeData = _nodeData;
      }
      nodeData.recalculateData();
			
			// Setting view.
		  view = new NodeView();
		  
		  if (canHasAnchor) {
		    drupalLinkIcon = new NodeActionIcon((new image_anchor()) as BitmapAsset);
		    view.addActionIcon(drupalLinkIcon);
		    drupalLinkIcon.toolTip = 'Follow link';
		    drupalLinkIcon.addEventListener(MouseEvent.CLICK, onClick_NodeLinkButton);
		  }
		  
		  if (canHasNormalChild) {
		    addNodeIcon = new NodeActionIcon((new image_add()) as BitmapAsset);
		    view.addActionIcon(addNodeIcon);
		    addNodeIcon.addEventListener(MouseEvent.CLICK, onClick_AddSimpleNodeButton);
		  }
			
      // Event listeners
      view.nodeComponentView.title_label.addEventListener(MouseEvent.DOUBLE_CLICK,   onDoubleClick);
      view.nodeComponentView.title_new.addEventListener(KeyboardEvent.KEY_UP,        onKeyUp_TitleTextField);
      view.nodeComponentView.title_new.addEventListener(FocusEvent.FOCUS_OUT,        onFocusOut_TitleTextField);
      view.nodeComponentView.addEventListener(MouseEvent.MOUSE_DOWN,                 onMouseDown);
      view.nodeComponentView.addEventListener(MouseEvent.MOUSE_UP,                   onMouseUp);
      view.nodeComponentView.addEventListener(MouseEvent.MOUSE_MOVE,                 onMouseMove);
      view.nodeComponentView.addEventListener(MouseEvent.MOUSE_OVER,                 onMouseOver);
      view.nodeComponentView.addEventListener(MouseEvent.MOUSE_OUT,                  onMouseOut);
      view.nodeComponentView.title_label.addEventListener(FlexEvent.UPDATE_COMPLETE, onUpdateComplete_TitleLabel);
      view.nodeComponentView.icon_has_child.addEventListener(MouseEvent.CLICK,       onClick_ToggleSubtreeButton);
      view.nodeComponentView.contextMenu = getContextMenu();
			view.nodeComponentView.title_label.text = nodeData.title;
			view.backgroundColor = nodeData.color;
			
			nodes.addItem(this);
			
			if (
			  FeatureController.isFeatureEnabled(FeatureController.TOOLTIPS) &&
			  nodeData.type == NodeType.NODE && 
			  nodeData.drupalID && 
			  nodeData.connection.isConnected
			) {
        nodeData.connection.call(
          'graphmind.getNodeView',
          function(result:Object):void {
            view.toolTip = result.toString();
          },
          ConnectionController.defaultRequestErrorHandler,
          nodeData.drupalID
        );
      }
			     
      EventCenter.notify(EventCenterEvent.NODE_CREATED, this);
		}
		
		
		/**
		 * Init static functionalities.
		 */
		public static function init():void {
		  // Node info panel
		  nodeConfigPanel = new ConfigPanelController('Node Settings');
		  nodeConfigComponent = new NodeInfo();
		  nodeConfigPanel.addItem(nodeConfigComponent);
		  nodeConfigComponent.saveTitleButton.addEventListener(MouseEvent.CLICK, onClick_saveTitleButton);
		  nodeConfigComponent.saveURLButton.addEventListener(MouseEvent.CLICK, onClick_saveURLButton);
		  
		  if (canHasAttributes && FeatureController.isFeatureEnabled(FeatureController.ATTRIBUTES)) {
  		  nodeAttributesPanel = new ConfigPanelController('Attributes');
  		  nodeAttributesComponent = new NodeAttributes();
  		  nodeAttributesPanel.addItem(nodeAttributesComponent);
  		  nodeAttributesComponent.attributesDataGrid.dataProvider = NodeViewController.selectedNodeData;
  		  nodeAttributesComponent.saveButton.addEventListener(MouseEvent.CLICK, onClick_saveAttributeButton);
  		  nodeAttributesComponent.removeButton.addEventListener(MouseEvent.CLICK, onClick_removeAttributeButton);
  		}
		  
		  nodeIconsPanel = new ConfigPanelController('Icons');
		  nodeIconsComponent = new NodeIcons();
		  nodeIconsPanel.addItem(nodeIconsComponent);
		  EventCenter.subscribe(EventCenterEvent.ICON_SELECTED, onIconSelected);
		  
		  loadDrupalItemPanel = new ConfigPanelController('Load Drupal item');
		  loadDrupalItemComponent = new DrupalItemLoadPanel();
		  loadDrupalItemPanel.addItem(loadDrupalItemComponent);
		  loadDrupalItemComponent.submitButton.addEventListener(MouseEvent.CLICK, onClick_loadDrupalItemSubmitButton);
		  loadDrupalItemPanel.addExitItem(loadDrupalItemComponent.submitButton);
		  
		  loadDrupalViewsComponent = new ViewLoadPanel();
		  loadDrupalViewsPanel = new ConfigPanelController('Load Drupal Views lists');
		  loadDrupalViewsPanel.addItem(loadDrupalViewsComponent);
		  loadDrupalViewsComponent.submitButton.addEventListener(MouseEvent.CLICK, onClick_loadDrupalViewsSubmitButton);
		  loadDrupalViewsPanel.addExitItem(loadDrupalViewsComponent.submitButton);
		}
		
		
		/**
		 * Create a simple empty child node.
		 * Don't use it for creating nodes. Use NodeFactory instead.
		 */
    public function createSimpleNodeChild():void {
      var node:NodeViewController = new NodeViewController();
      addChildNode(node);
      node.select();
      node.setEditMode();
    }
    
    
		/**
		 * Get a complete context menu for the UI.
		 */	
		public function getContextMenu():ContextMenu {
			var contextMenu:ContextMenu = new ContextMenu();
			contextMenu.customItems = [];
			contextMenu.hideBuiltInItems();
			
			var cms:Array = [];
			cms.push({title: 'Node info', event: onContextMenuSelected_NodeInfo, separator: false});
			if (canHasAttributes && FeatureController.isFeatureEnabled(FeatureController.ATTRIBUTES)) {
			 cms.push({title: 'Attributes', event: onContextMenuSelected_NodeAttributes, separator: false});
			}
      cms.push({title: 'Icons', event: onContextMenuSelected_NodeIcons, separator: false});
			cms.push({title: 'Add node', event: onContextMenuSelected_AddSimpleNode, separator: false});
			if (FeatureController.isFeatureEnabled(FeatureController.LOAD_DRUPAL_NODE)) {
			  cms.push({title: 'Load Drupal item', event: onContextMenuSelected_AddDrupalItem, separator: false});
			}
			if (FeatureController.areFeaturesEnabled([FeatureController.LOAD_DRUPAL_NODE, FeatureController.LOAD_DRUPAL_VIEWS_LIST])) {
			  cms.push({title: 'Load Views list', event: onContextMenuSelected_AddDrupalViews, separator: false});
			}
			cms.push({title: 'Remove node',     event: onContextMenuSelected_RemoveNode,       separator: true});
			cms.push({title: 'Expand subtree',    event: onContextMenuSelected_OpenSubtree,      separator: true});
			cms.push({title: 'Toggle cloud',    event: onContextMenuSelected_ToggleCloud,      separator: false});
			
			if (NodeType.updatableTypes.indexOf(nodeData.type) >= 0) {
				cms.push({title: 'Fetch Drupal data', event: onContextMenuSelected_UpdateDrupalItem, separator: false});
			}
			
			// Extend context menu items by Plugin provided menu items
			PluginManager.alter('context_menu', cms);
			
			for each (var cmData:Object in cms) {
				var cmi:ContextMenuItem = new ContextMenuItem(cmData.title,	cmData.separator);
				cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(_event:ContextMenuEvent):void {
					select();
				});
				cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, cmData.event);
				contextMenu.customItems.push(cmi);
			}
			
			return contextMenu;
		}
    
		
		/**
		 * Select a single node on the mindmap stage.
		 * Only one node can be active at a time.
		 * Accessing to this node: TreeManager.getInstance().activeNode():NodeItem.
		 */
		public function select():void {
		  EventCenter.notify(EventCenterEvent.NODE_IS_SELECTED, this);
		  
      if (activeNode) {
        activeNode.unselect();
      }
      activeNode = this;
      
			var isTheSameSelected:Boolean = isSelected;
			// Not to lose focus from textfield
			if (!isTheSameSelected) view.setFocus();
			
			isSelected = true;
			
			selectedNodeData.removeAll();
      for (var key:* in nodeData.drupalData) {
        selectedNodeData.addItem({
          key: key,
          value: nodeData.drupalData[key]
        });
      }     
      
      nodeConfigComponent.nodeLabelRTE.htmlText = view.nodeComponentView.title_label.htmlText || view.nodeComponentView.title_label.text;
      nodeConfigComponent.urlField.text = nodeData.link;
      
      if (nodeAttributesComponent) {
        nodeAttributesComponent.attrKey.text = '';
        nodeAttributesComponent.attrValue.text = '';
      }

			_setBackgroundEffect(EFFECT_HIGHLIGHT);
		}
		
		
		/**
		 * Deselect node.
		 */
		public function unselect():void {
		  EventCenter.notify(EventCenterEvent.NODE_IS_UNSELECTED, this);
			_setBackgroundEffect(EFFECT_NORMAL);
		}
		
		
		/**
		 * Create Freemind compatible XML string output.
		 * For the full XML call it in StageManager.
		 */
		public function exportToFreeMindFormat():String {
			//var titleIsHTML:Boolean = _displayComponent.title_label.text != _displayComponent.title_label.htmlText;
			var titleIsHTML:Boolean = nodeData.title.toString().indexOf('<') >= 0;
			
			// Base node information
			var output:String = '<node ' + 
				'CREATED="'  + nodeData.created   + '" ' + 
				'MODIFIED="' + nodeData.updated  + '" ' + 
				'ID="'       + nodeData.id        + '" ' + 
				'FOLDED="'   + (_isForcedCollapsed ? 'true' : 'false') + '" ' + 
				(titleIsHTML ? '' : 'TEXT="' + escape(nodeData.title) + '" ') + 
				(nodeData.link.length > 0 ? ('LINK="' + escape(nodeData.link) + '" ') : '') + 
				'TYPE="' + nodeData.type + '" ' +
				">\n";
			
			if (titleIsHTML) {
				output = output + "<richcontent TYPE=\"NODE\"><html><head></head><body>" + 
					nodeData.title + 
					"</body></html></richcontent>";
			}
			
			var key:*;
			for (key in nodeData.drupalData) {
				output = output + '<attribute NAME="' + escape(key) + '" VALUE="' + escape(nodeData.drupalData[key]) + '"/>' + "\n";
			}
			
			if (nodeData.connection && nodeData.connection.target) {
        output = output + '<site URL="' + escape(nodeData.connection.target) + '" />' + "\n";
			}
			
			for each (var iconName:* in nodeData.icons) {
				output = output + '<icon BUILTIN="' + iconName + '"/>' + "\n";
			}
			
			for each (var arrowLink:TreeArrowLink in _arrowLinks) {
			  output = output + '<arrowlink DESTINATION="' + arrowLink.destinationNode.nodeData.id + '"/>' + "\n";
			}
			
			if (hasCloud()) {
				output = output + '<cloud/>' + "\n";
			}
			
			// Add childs
			for each (var child:NodeViewController in _children) {
				output = output + child.exportToFreeMindFormat();
			}
			
			return output + '</node>' + "\n";
		}
		
		
		/**
		 * Show the dialog for loading a Drupal item.
		 */
		protected function loadItem():void {
			select();
			loadDrupalItemPanel.show();
		}
		
		
		/**
		 * Show the dialog for loading a Drupal Views list.
		 */
		protected function loadViews():void {
			select();
			loadDrupalViewsPanel.show();
			loadDrupalViewsComponent.view_arguments.text = nodeData.drupalID.toString();
		}
		
		
		/**
		 * Remove each child of the node.
		 */
		protected function _removeNodeChilds():void {
			while (_children.length > 0) {
				(_children.getItemAt(0) as NodeViewController).kill();
			}
		}
		
		
		/**
		 * Kill a node and each childs.
		 */
		public function kill():void {
		  // Root can't be deleted.
			if (!parent) return;
			
			// @HOOK
			EventCenter.notify(EventCenterEvent.NODE_IS_KILLED, this);
			
			// Remove all children the same way.
			_removeNodeChilds();
			
			if (parent) {
				// Remove parent's child (this child).
				parent._children.removeItemAt(parent._children.getItemIndex(this));
				// Check parent's toggle-subtree button. With no child it should be hidden.
				parent.view.nodeComponentView.icon_has_child.visible = parent._children.length > 0;
			}

      // Remove arrow links.			
      for each (var arrowLink:TreeArrowLink in TreeArrowLink.arrowLinks) {
        if (arrowLink.destinationNode == this || arrowLink.sourceNode == this) {
          arrowLink.sourceNode.removeArrowLink(arrowLink);
        }
      }
			
			// Remove main UI element.
			view.nodeComponentView.parent.removeChild(view.nodeComponentView);
			// Remove the whole UI.
			view.parent.removeChild(this.view);
			
			// Remove from the global storage
			nodes.removeItemAt(nodes.getItemIndex(this));
			
			// Update tree.
			EventCenter.notify(EventCenterEvent.MAP_UPDATED, this);
			
			update(UP_UI);
			
			delete this; // :.(
		}
		
		
		/**
		 * Check if the giveth node is a child of the self node.
		 */
		public function isChild(node:NodeViewController):Boolean {
			for each (var child:NodeViewController in _children) {
				if (child == node) {
					return true;
				}
				if (child.isChild(node)) return true;
			}
			
			return false;
		}
		
		
		/**
		 * Move a node.
		 * :: target -> this
		 */
		public function move(target:NodeViewController):void {
		  _moveToParent(target);
		  
      EventCenter.notify(EventCenterEvent.NODE_DID_MOVED, this);
		}
		
		
		/**
		 * Move node to a new parent.
		 */
		private function _moveToParent(target:NodeViewController):Boolean{
      // No parent can detach child.
      if (!this || !this.parent || !target) return false;
      // Target is an ascendant of the source.
      if (this.isChild(target)) return false;
      // Source is equal to target
      if (this == target) return false;
      
      EventCenter.notify(EventCenterEvent.NODE_WILL_BE_MOVED, this);
      
      // Remove source from parents childs
      this.removeFromParentsChilds();
      // Add source to target
      target.addChildNode(this);
      // Refresh display
      
      this.update(UP_UI);

      return true;
		}
		
		
		/**
		 * Move a node to a next sibling.
		 */
		public function moveToPrevSibling(target:NodeViewController):void {
		  if (this == target) return;
		  
			if (_moveToParent(target.parent)) {
				var siblingIDX:int = target.parent._children.getItemIndex(target);
				if (siblingIDX == -1) {
					return;
				}
				
				for (var i:int = target.parent._children.length - 1; i > siblingIDX; i--) {
					target.parent._children[i] = target.parent._children[i - 1];
				}
				
				target.parent._children.setItemAt(this, siblingIDX);
				
        EventCenter.notify(EventCenterEvent.NODE_DID_MOVED, this);
				EventCenter.notify(EventCenterEvent.MAP_UPDATED);
			}
		}
		
		
    /**
     * Move a node to a next sibling.
     */
    public function moveToNextSibling(target:NodeViewController):void {
      if (this == target) return;
      
      if (_moveToParent(target.parent)) {
        var siblingIDX:int = target.parent._children.getItemIndex(target) + 1;
        if (siblingIDX == -1) {
          return;
        }
        
        for (var i:int = target.parent._children.length - 1; i > siblingIDX; i--) {
          target.parent._children[i] = target.parent._children[i - 1];
        }
        
        target.parent._children.setItemAt(this, siblingIDX);
        
        EventCenter.notify(EventCenterEvent.NODE_DID_MOVED, this);
        EventCenter.notify(EventCenterEvent.MAP_UPDATED);
      }
    }
		
		
		/**
		 * Remove this node from it's parent's child collection.
		 * It doesn't do any delete or kill.
		 */
		protected function removeFromParentsChilds():void {
			var childIDX:int = parent._children.getItemIndex(this);
			if (childIDX >= 0) {
				this.parent._children.removeItemAt(childIDX);
			}
			
			parent.view.nodeComponentView.icon_has_child.visible = parent._children.length > 0;
		}
 		
 		
 		/**
 		 * Event callback - double click on an icon (normal decorator icon).
 		 */
 		protected function onDoubleClick_icon(event:MouseEvent):void {
 		  removeIcon(event.currentTarget as Image);
 		}

 		
 		/**
 		 * Remove an icon.
 		 */
 		public function removeIcon(icon:Image):void {
      var iconName:String = StringUtility.iconUrlToIconName(icon.source.toString());
      nodeData.icons.removeItemAt(nodeData.icons.getItemIndex(iconName));
      view.removeIcon(icon.source.toString());
      update(UP_UI);
 		}
 		
 		
 		/**
 		 * Set a link.
 		 */
		public function setLink(link:String):void {
			nodeData.link = link;
			if (canHasAnchor) {
			  drupalLinkIcon.visible = (link.length > 0);
			}
			update(UP_UI);
		}
		
		
		/**
		 * Toggle cloud.
		 */
		public function toggleCloud():void {
			nodeData.hasCloud ? disableCloud() : enableCloud();
		}
		
		
		/**
		 * Enable cloud.
		 */
		public function enableCloud():void {
		  nodeData.hasCloud = true;
		  update(UP_UI);
		}
		
		
		/**
		 * Disable cloud.
		 */
		public function disableCloud():void {
		  nodeData.hasCloud = false;
		  update(UP_UI);
		}
		

		/**
		 * Check if the subtree is collapsed.
		 */
		public function isCollapsed():Boolean {
			return _isCollapsed;
		}

		
		/**
		 * Make a request for updating the node from Drupal.
		 */
		public function requestForUpdate():void {
      if (nodeData.connection.isConnected) {
        nodeData.connection.call(
          nodeData.type + '.get',
          function(result:Object):void{updateDrupalItem(result);},
          null,
          nodeData.drupalID
        ); 
      } else {
        OSD.show('This node cannot be upadted.', OSD.WARNING);
      }
		}

		
		/**
		 * Update from Drupal request is arrived.
		 * @param object placeholder - we're using this as a callback. The second param
		 *  is a node (in this case the same) that has to be updated. We don't need that now.
		 */
		public function updateDrupalItem(result:Object):void {
			for (var key:* in result) {
				nodeData.drupalData[key] = result[key];
			}
			nodeData.recalculateData();
			setTitle(nodeData.title);
			select();
			update(UP_UI);
		}

		
		/**
		 * Get parent node.
		 */
		public function getParentNode():ITreeNode {
			return parent;
		}

		
		/**
		 * Get the secondary connections - represented by arrow links.
		 */
		public function getArrowLinks():ArrayCollection {
			return _arrowLinks;
		}

		
		/**
		 * Add new secondary connection as an arrow link.
		 */
		public function addArrowLink(arrowLink:TreeArrowLink):void {
			this._arrowLinks.addItem(arrowLink);
			update(UP_UI);
			
			arrowLink.doubleClickEnabled = true;
			arrowLink.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick_arrowLink);
		}
		
		
		/**
		 * Check if the subtree has a cloud.
		 */
		public function hasCloud():Boolean {
			return nodeData.hasCloud;
		}
		
		
		/**
		 * Get a child node that has equal data.
		 */
		public function getEqualChild(data:Object, type:String):NodeViewController {
			for each (var child:NodeViewController in _children) {
				if (child.nodeData.equalTo(data, type)) return child;
			}
			return null;
		}


    /**
     * Set the title of the node. For title should be called every time!
     * 
     * @param boolean userChange - indicates if the change was done by user interaction.
     */
		public function setTitle(title:String):void {
      nodeData.title = view.nodeComponentView.title_label.htmlText = title;
      view.nodeComponentView.title_label.explicitWidth = NaN;
      view.nodeComponentView.title_label.invalidateSize();
      
		  EventCenter.notify(EventCenterEvent.NODE_TITLE_CHANGED, this);
			
			update(UP_UI);
		}
		
		
		/**
		 * Return true if the node has children.
		 */
		public function hasChild():Boolean {
			return _children.length > 0;
		}
    
    
    /**
    * Override toString.
    */
    public override function toString():String {
      return '[NodeViewController: ' + this.nodeData.id + ']';
    }
    
		
    /**
     * Update node.
     * 
     * Reasons:
     *  - modified title
     *  - changed attributes
     *  - toggled cloud
     * 
     * @param uint updateSet - binary flag
     *  UP_NODE_UI | UP_TREE_UI
     */
    public function update(updateSet:uint = 0):void {
      nodeData.updated = (new Date()).time;
      
      if (updateSet & UP_UI) {
        view.isGraphicsUpdated = true;
        view.refreshGraphics();
      }
      
      EventCenter.notify(EventCenterEvent.MAP_UPDATED);
    }
    
    
    /**
    * Refresh node view by it's data.
    * Refrech color, data and title.
    */
    public function refreshWithNewData():void {
      nodeData.recalculateData();
      setTitle(nodeData.title);
      setColor(nodeData.color);
      update(UP_UI);
    }
    
    
    /**
    * Set color.
    */
    public function setColor(color:uint):void {
      if (!color) return;
       
      nodeData.color = color;
      view.backgroundColor = color;
      view.isGraphicsUpdated = true;
      
      update(UP_UI);
    }

    
    /**
     * Add attribute.
     */
    public function addData(attribute:String, value:String):void {
      nodeData.dataAdd(attribute, value);
      select();
      update();
    }
    
    
    /**
     * Remove attribute.
     */
    public function deleteData(param:String):void {
      nodeData.dataDelete(param);
      select();
      update();
    }
    

    /**
    * Event callback - mouse over.
    */
    protected function onMouseOver(event:MouseEvent):void {
      _mouseSelectionTimeout = setTimeout(select, 400);
      if (canHasNormalChild) {
        addNodeIcon.visible = ApplicationController.i.isEditable();
      }
      if (canHasAnchor) {
        drupalLinkIcon.visible = nodeData.link.length > 0;
      }
    }
    
    
    /**
    * Event callback - mouse out.
    */
    protected function onMouseOut(event:MouseEvent):void {
      clearTimeout(_mouseSelectionTimeout);
      if (canHasNormalChild) {
        addNodeIcon.visible = false;
      }
      if (canHasAnchor) {
        drupalLinkIcon.visible = false;
      }
      
      if (NodeViewController.isPrepairedNodeDragAndDrop) {
        EventCenter.notify(EventCenterEvent.NODE_START_DRAG, this);
      }
      
      view.nodeComponentView.insertLeft.visible = false;
      view.nodeComponentView.insertUp.visible = false;
    }
    
    
    /**
    * Event callback - double click.
    */
    protected function onDoubleClick(event:MouseEvent):void {
      if (!ApplicationController.i.isEditable()) return;
      
      view.nodeComponentView.currentState = 'edit_title';
      view.nodeComponentView.title_new.text = view.nodeComponentView.title_label.text;
      view.nodeComponentView.title_new.setFocus();
    }
    
    
    /**
    * Event callback - key up event on the label edit field.
    */
    protected function onKeyUp_TitleTextField(event:KeyboardEvent):void {
      if (!ApplicationController.i.isEditable()) return;
      
      if (event.keyCode == Keyboard.ENTER) {
        closeLabelEditMode();
        select();
      } else if (event.keyCode == Keyboard.ESCAPE) {
        view.nodeComponentView.currentState = '';
        view.nodeComponentView.title_new.text = view.nodeComponentView.title_label.text;
      }
    }
    
    
    /**
    * Event callback - focus loss on the label edit field.
    */
    protected function onFocusOut_TitleTextField(event:FocusEvent):void {
      if (!ApplicationController.i.isEditable()) return;
      closeLabelEditMode();
    }
    
    
    /**
    * Finish label editing mode.
    */
    private function closeLabelEditMode():void {
      view.nodeComponentView.currentState = '';
      setTitle(view.nodeComponentView.title_new.text);
      GraphMind.i.setFocus();
    }
    
    
    /**
    * Event callback - click on the load item context menu item.
    */
    protected function onClick_itemLoaderSelector(event:MouseEvent):void {
      event.stopPropagation();
      select();
    }
    
    
    /**
    * Event callback - click on the add node icon.
    */
    protected function onClick_AddSimpleNodeButton(event:MouseEvent):void {
      if (!ApplicationController.i.isEditable()) return;
      
      event.stopPropagation();
      event.stopImmediatePropagation();
      event.preventDefault();
      createSimpleNodeChild();
    }
    
    
    /**
    * Event callback - click on the load item context menu item.
    */
    protected function onClick_loadItem(event:MouseEvent):void {
      event.stopPropagation();
      loadItem();
    }
    
    
    /**
    * Event callback - click on the load view context menu item.
    */
    protected function onClick_loadView(event:MouseEvent):void {
      event.stopPropagation();
      loadViews();
    }
    
    
    /**
    * Event callback - click on the anchor icon.
    */
    protected function onClick_NodeLinkButton(event:MouseEvent):void {
      var ur:URLRequest = new URLRequest(nodeData.link);
      navigateToURL(ur, '_blank');
    }
    
    
    /**
    * Event callback - click on the node.
    */
    protected function onMouseDown(event:MouseEvent):void {
      if (!ApplicationController.i.isEditable()) return;
      
      EventCenter.notify(EventCenterEvent.NODE_PREPARE_DRAG, this);
      event.stopImmediatePropagation();
    }
    
    
    /**
    * Event callback - mouse up on node.
    */
    protected function onMouseUp(event:MouseEvent):void {
      if (!ApplicationController.i.isEditable()) return;
      
      if (NodeViewController.isNodeDragAndDrop) {
        if (view.mouseX / view.width > (1 - view.mouseY / view.height)) {
          NodeViewController.dragAndDrop_sourceNode.move(this);
        } else {
          NodeViewController.dragAndDrop_sourceNode.moveToPrevSibling(this);
        }
      }
      
      // Kill node drag and drop
      if (NodeViewController.isNodeDragAndDrop || NodeViewController.isPrepairedNodeDragAndDrop) {
        EventCenter.notify(EventCenterEvent.NODE_FINISH_DRAG, this);
      }
    }
    
    
    /**
    * Event callback - mouse move on node.
    */
    protected function onMouseMove(event:MouseEvent):void {
      if (!ApplicationController.i.isEditable()) return;
      
      if ((!NodeViewController.isPrepairedNodeDragAndDrop) && NodeViewController.isNodeDragAndDrop) {
        if (view.mouseX / view.width > (1 - view.mouseY / NodeView.HEIGHT)) {
          view.nodeComponentView.insertLeft.visible = true;
          view.nodeComponentView.insertUp.visible = false;
        } else {
          view.nodeComponentView.insertLeft.visible = false;
          view.nodeComponentView.insertUp.visible = true;
        }
      }
    }
    
    
    /**
    * Event callback - click on the add node context menu.
    */
    protected function onContextMenuSelected_AddSimpleNode(event:ContextMenuEvent):void {
      createSimpleNodeChild();
    }
    
    
    /**
    * Event callback - click on the add drupal item context menu.
    */
    protected function onContextMenuSelected_AddDrupalItem(event:ContextMenuEvent):void {
      loadItem();
    }
    
    
    /**
    * Event callback - on click on the add views context menu.
    */
    protected function onContextMenuSelected_AddDrupalViews(event:ContextMenuEvent):void {
      loadViews();
    }
    
    
    /**
    * Event callback - on click on the remove node context menu.
    */
    protected function onContextMenuSelected_RemoveNode(event:ContextMenuEvent):void {
      kill();
    }
  
    
    /**
    * Event callback - on click on the toggle subtree icon. 
    */
    protected function onClick_ToggleSubtreeButton(event:MouseEvent):void {
      if (!this._isCollapsed) {
        collapse();
      } else {
        uncollapse();
      }
      
      EventCenter.notify(EventCenterEvent.MAP_UPDATED);
      event.stopPropagation();
    }
    
    
    /**
    * Event callback - on click on the open full subtree context menu. 
    */
    protected function onContextMenuSelected_OpenSubtree(event:ContextMenuEvent):void {
      uncollapseChilds(true);
    }
  
    
    /**
    * Event callback - on click on the toggle cloud context menu. 
    */
    protected function onContextMenuSelected_ToggleCloud(event:ContextMenuEvent):void {
      toggleCloud();
    }
  
  
    /**
    * Event callback - on click on the update drupal item context menu.
    */
    protected function onContextMenuSelected_UpdateDrupalItem(event:ContextMenuEvent):void {
      requestForUpdate();
    }
    
    
    /**
    * Event callback - node title label ui is updated.
    */
    protected function onUpdateComplete_TitleLabel(event:FlexEvent):void {
      update(UP_UI);
    }
    
    
    /**
    * Event callback - doble click on an arrow link.
    */
    protected function onDoubleClick_arrowLink(event:MouseEvent):void {
      removeArrowLink(event.target as TreeArrowLink);
    }
        
    
    /**
    * Get children.
    */
    public function getChildNodeAll():ArrayCollection {
      return _children;
    }
    
    
    /**
     * Add a new child node.
     */
    public function addChildNode(node:NodeViewController):void {
      // Add node as a new child
      this._children.addItem(node);
      node.parent = this;
      
      // Open subtree recursively.
      // When a node is added to a folded subtree, we have to open all.
      var parent:NodeViewController = this;
      while (true) {
        parent.uncollapseChilds();
        if (parent.parent) {
          parent = parent.parent;
        } else {
          break;
        }
      }
      
      // Showing toggle-subtree button.
      view.nodeComponentView.icon_has_child.visible = true;
      
      // Not necessary to fire NODE_ATTCHED event. MOVED and CREATED covers this.
      update(UP_UI);
      
      EventCenter.notify(EventCenterEvent.NODE_DID_ADDED_TO_PARENT, node);
    }
    
    
    /**
    * Collapse subtree of the node.
    */
    public function collapse():void {
      _isForcedCollapsed = true;
      collapseChilds();
    }
    
    
    /**
    * Collapse subtrees recursively.
    */
    protected function collapseChilds():void {
      _isCollapsed = true;
      view.nodeComponentView.icon_has_child.source = view.nodeComponentView.image_node_uncollapse;
      for each (var nodeItem:NodeViewController in _children) {
        nodeItem.view.visible = false;
        nodeItem.collapseChilds();
      }
      update(UP_UI);
    }

    
    /**
    * Open subtree of the node.
    */
    public function uncollapse():void {
      _isForcedCollapsed = false;
      uncollapseChilds();
    }

    
    /**
    * Open subtrees recursively.
    */
    protected function uncollapseChilds(forceOpenSubtree:Boolean = false):void {
      _isCollapsed = false;
      view.nodeComponentView.icon_has_child.source = view.nodeComponentView.image_node_collapse;
      for each (var nodeItem:NodeViewController in _children) {
        nodeItem.view.visible = true;
        if (!nodeItem._isForcedCollapsed || forceOpenSubtree) {
          nodeItem.uncollapseChilds(forceOpenSubtree);
        }
      }
      update(UP_UI);
    }

    
    /**
    * Set background effect of the view.
    */
    private function _setBackgroundEffect(effect:int = EFFECT_NORMAL):void {
      view.backgroundView.filters = (effect == EFFECT_NORMAL) ? [] : [_nodeInnerGlowFilter, _nodeInnerGlowFilter2, _nodeGlowFilter];
    }


    /**
     * Add icon.
     */
    public function addIcon(source:String):void {
      // Getting the normal icon name only
      var iconName:String = StringUtility.iconUrlToIconName(source);
      
      // Icon is already exists
      for each (var _iconName:String in nodeData.icons) {
        // It already exists.
        if (_iconName == iconName) return;
      }
      
      var icon:Image = new Image();
      icon.source = source;
      icon.y = 2;
      
      view.addIcon(icon);
      nodeData.addIcon(iconName);
      
      if (ApplicationController.i.isEditable()) {
        icon.doubleClickEnabled = true;
        icon.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick_icon);
      }
    
      update(UP_UI);
    }
    
    
    /**
    * Remove extra connection.
    */
    public function removeArrowLink(arrowLink:TreeArrowLink):void {
      TreeArrowLink.arrowLinks.removeItemAt(TreeArrowLink.arrowLinks.getItemIndex(arrowLink));
      _arrowLinks.removeItemAt(_arrowLinks.getItemIndex(arrowLink));
    }
    
    
    /**
    * Set edit mode -> entering title.
    */
    public function setEditMode():void {
      view.nodeComponentView.currentState = 'edit_title';
      view.nodeComponentView.title_new.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:FlexEvent):void{
        view.nodeComponentView.title_new.setFocus();
      });
    }
    
    
    private function onContextMenuSelected_NodeInfo(e:ContextMenuEvent):void {
      nodeConfigPanel.show();
    }
    
    
    private function onContextMenuSelected_NodeAttributes(e:ContextMenuEvent):void {
      nodeAttributesPanel.show();
    }
    
    
    private function onContextMenuSelected_NodeIcons(e:ContextMenuEvent):void {
      nodeIconsPanel.show();
    }
    
    
    private static function onClick_saveTitleButton(e:MouseEvent):void {
      activeNode.setTitle(nodeConfigComponent.nodeLabelRTE.htmlText);
    }
    
    
    private static function onClick_saveURLButton(e:MouseEvent):void {
      activeNode.setLink(nodeConfigComponent.urlField.text);
    }
    
    
    private static function onClick_saveAttributeButton(e:MouseEvent):void {
      if (!activeNode) return;
      activeNode.addData(nodeAttributesComponent.attrKey.text, nodeAttributesComponent.attrValue.text);
    }
    
    
    private static function onClick_removeAttributeButton(e:MouseEvent):void {
      if (!activeNode) return;
      activeNode.deleteData(nodeAttributesComponent.attrKey.text);
    }
    
    
    private static function onIconSelected(e:EventCenterEvent):void {
      if (!activeNode) return;
      activeNode.addIcon(((e.data as MouseEvent).currentTarget as Image).source.toString());
    }
    
    
    private static function onClick_loadDrupalItemSubmitButton(e:MouseEvent):void {
      var temp:DrupalItemRequestParamObject = new DrupalItemRequestParamObject();
      temp.type = loadDrupalItemComponent.drupalTypeField.selectedItem.data;
      temp.conn = loadDrupalItemComponent.sourceConnectionField.selectedItem as Connection;
      temp.id = loadDrupalItemComponent.drupalIDField.text;
      temp.parentNode = activeNode;

      EventCenter.notify(EventCenterEvent.LOAD_DRUPAL_ITEM, temp);
    }
    
    
    private static function onClick_loadDrupalViewsSubmitButton(e:MouseEvent):void {
      var views:DrupalViewsQuery = new DrupalViewsQuery();
      views.args   = loadDrupalViewsComponent.view_arguments.text;
      views.limit  = parseInt(loadDrupalViewsComponent.view_limit.text);
      views.offset = parseInt(loadDrupalViewsComponent.view_offset.text);
      views.name   = loadDrupalViewsComponent.view_name.text;
      views.views  = loadDrupalViewsComponent.view_views_datagrid.selectedItem as DrupalViews;
      
      var temp:DrupalViewsRequestParamObject = new DrupalViewsRequestParamObject();
      temp.parentNode = activeNode;
      temp.views = views;
      
      EventCenter.notify(EventCenterEvent.LOAD_DRUPAL_VIEWS, temp);
    }
    
	}
	
}

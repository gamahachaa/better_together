package views;
import haxe.ui.components.Column;
import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;

/**
 * ...
 * @author bb
 */
@:build(haxe.ui.ComponentBuilder.build("assets/ui/better_together.xml"))
class MainView extends VBox 
{

	public function new() 
	{
		super();
		var header = new Header();
		var footer = new Footer();
	}
	/***********************************************
	/***************** EVENTS      *****************
	/***********************************************/
	/**
	 * CHANGE
	 */
	@:bind(reasons_categories_tree, UIEvent.CHANGE)
	function onTreeChanged(e:UIEvent):Void
	{
        trace(e.target.id);
	}
	/**
	 *  Click
	 */
	@:bind(details_person_selector_button, MouseEvent.CLICK)
	function onSearchAgent(e:MouseEvent):Void
	{
        trace(e.target.id);
	}
	@:bind(reasons_printscreen_button, MouseEvent.CLICK)
	function onOpenImage(e:MouseEvent):Void
	{
        trace(e.target.id);
	}
	/*@:bind(reasons_description_defect_label, MouseEvent.CLICK)
	function onMarkdownHelp(e:MouseEvent):Void
	{
        trace(e.target.id);
	}*/
	@:bind(reasons_description_defect_label, MouseEvent.CLICK)
	@:bind(reasons_description_fix_label, MouseEvent.CLICK)
	function onMarkdownHelp(e:MouseEvent):Void
	{
        trace(e.target.id);
	}
	
	@:bind(details_person_selector_display_tableview.findComponent("selected", Column), MouseEvent.CLICK)
	function toggleSelectAll(e:MouseEvent):Void
	{
        trace(e.target.id);
	}
	
}
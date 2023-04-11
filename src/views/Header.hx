package views;

import haxe.ui.components.Image;
import haxe.ui.containers.HBox;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import signal.Signal.Signal0;

/**
 * ...
 * @author bb
 */
@:build(haxe.ui.ComponentBuilder.build("assets/ui/metadatas/header.xml"))
class Header extends HBox 
{
	public var signalLogoff:Signal0;
    @bind(app_label.text)
	public var app_label_text:String;
	
	@bind(username_label.text)
	public var username_label_text:String;

	@bind(thumbnail.resource)
	public var thumbnail_resource:String;
	
	
	
	/**
	 * 
	 */
	public function new() 
	{
		super();
		this.id = "header";
		this.thumbnail.imageScale = 1.2;
		signalLogoff = new Signal0();
	}
	/**
	 *  Click
	 */
	@:bind(logoff_button, MouseEvent.CLICK)
	dynamic public function onLogOff(e:MouseEvent):Void
	{
        #if debug
		trace(e.target.id);
		#end
		signalLogoff.dispatch();
	}
	@:bind(app_label, MouseEvent.CLICK)
	function onAppLabelClicked(e:MouseEvent):Void
	{
        trace(e.target.id);
	}
	/**
	 * CHANGE
	 */
	@:bind(langSwitcher_group, UIEvent.CHANGE)
	function onLangChanged(e:UIEvent):Void
	{
        trace(e.target.id);
	}
}
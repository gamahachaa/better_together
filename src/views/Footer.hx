package views;

import haxe.ui.containers.HBox;
import haxe.ui.events.MouseEvent;

/**
 * ...
 * @author bb
 */
@:build(haxe.ui.ComponentBuilder.build("assets/ui/metadatas/footer.xml"))
class Footer extends HBox
{
    @bind(version_label.text)
	public var version_label_text:String;
	public function new()
	{
		super();
		this.id = "footer";

	}
	/**
	*  Click
	*/
	@:bind(send_button, MouseEvent.CLICK)
	function onSend(e:MouseEvent):Void
	{
		trace(e.target.id);
	}
}
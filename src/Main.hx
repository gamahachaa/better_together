package ;
import haxe.ui.Toolkit;
import haxe.ui.components.DropDown.CalendarDropDownHandler;
import tests.XapiSendSerialized;
import tm.TMApp;

/**
 * --resource assets/ui/inbound.xml@inbound
--resource assets/ui/outbound.xml@outbound
--resource assets/ui/mail.xml@mail
--resource assets/ui/case.xml@case
 */


class Main
{
	
	public static var _mainDebug:Bool;
	public static function main()
	{
		CalendarDropDownHandler.DATE_FORMAT = "%d.%m.%Y";
		//
		//trace("wtf");
		var main = new tm.TMApp();
		//var main = new XapiSendSerialized();
	}	
}
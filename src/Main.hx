package ;
import bt.BTApp;
import haxe.ui.Toolkit;
import haxe.ui.components.DropDown.CalendarDropDownHandler;
import js.Browser;
import js.html.URLSearchParams;
import tests.XapiSendSerialized;
//import tm.TMApp;

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
		var main = new BTApp();
		/**
		 * KEEP for URL prefilling from Qook
		 */
		//trace(Browser.location.search);
		//var u = new URLSearchParams(Browser.location.search);
		//trace(u.has("user"));
		//trace(u.get("user")); 
		//trace(u.has("page"));
		//trace(u.get("page"));
		
	}	
}
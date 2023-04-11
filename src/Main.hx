package ;
import bt.BTApp;
import bt.VoidApp;
import xapi.Params;
//import haxe.ui.Toolkit;
//import haxe.ui.components.DropDown.CalendarDropDownHandler;
import js.Browser;
import js.html.URLSearchParams;
//import tests.XapiSendSerialized;
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
	public static var PARAMS:URLSearchParams;
	static var m:AppBase;
	//static inline var VOID_PARAM:String = "void";
	public static function main()
	{
		//CalendarDropDownHandler.DATE_FORMAT = "%d.%m.%Y";
		var s = Browser.location.search;
		PARAMS = new URLSearchParams(s);
		
		//trace("WTF");
		if (PARAMS.has(Params.VOID)){
			m = new bt.VoidApp();
		}
		else{
			//m = new BTApp();
			m = new BTAppNew();
		}
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

/*Action
Coaching
Group Training
Warning
Dismissal
Leaver
Disputed feedback
	
Status
Agent absent
Completed
No action

Reason (Disputed feedback)
Wrong agent
No mistake made
  */
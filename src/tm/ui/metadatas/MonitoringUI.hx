package tm.ui.metadatas;

import haxe.ui.containers.VBox;
import haxe.ui.events.UIEvent;
import signal.Signal1;

/**
 * ...
 * @author bb
 */
@:build(haxe.ui.macros.ComponentMacros.build("assets/ui/metadatas/Monitoring.xml"))
class MonitoringUI extends VBox 
{
	var r:String;
	var t:String;
	public var typeSignal(get, null):signal.Signal1<String>;
	public var ressonSignal(get, null):UIEvent->formSignal.dispatch;
	
	
	//////////////////// public /////////////////////////
	public function new() 
	{
		super();
		t = "";
		r = "";
		ressonSignal = new Signal1<String>();
		typeSignal = new Signal1<String>();
		reason.onChange = (e:UIEvent)->(ressonSignal.dispatch(r = e.target.id));
		monitoringType.onChange = (e:UIEvent)->(typeSignal.dispatch(t = e.target.id));
	}
	public function validateData()
	{
		var canSubmit = true;
		var message = [""];
		if (monitoringsummary.text == null || monitoringsummary.text.trim() == "")
		{
			canSubmit = false;
			message.push("{{ALERT_MONITORING_SUMMARY}}");
		}
		if (r == "")
		{
			
			canSubmit = false;
			message.push("{{ALERT_MONITORING_REASON}}");
		}
		if (t == "")
		{
			
			canSubmit = false;
			message.push("{{ALERT_MONITORING_TYPE}}");
		}
		return {canSubmit:canSubmit, message: message};
	}
	
	//////////////////// PRIVATE /////////////////////////
	function get_typeSignal():signal.Signal1<String> 
	{
		return typeSignal;
	}
	
	function get_ressonSignal():UIEvent->formSignal.dispatch 
	{
		return ressonSignal;
	}
}
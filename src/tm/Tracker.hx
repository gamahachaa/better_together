package tm;
import http.XapiHelper;
import js.Browser;
import roles.Actor;
import xapi.Agent;
import xapi.Verb;
import signals.Signal1;
import xapi.types.Score;
import xapi.types.StatementRef;
/**
 * ...
 * @author bb
 */
class Tracker extends XapiHelper
{
	//var xapi:http.XapiHelper;
	
	public var stage:Int;
	public var signal(get, null):signals.Signal1<Int>;
	public var coachRecieved(get, null):StatementRef;
	public var monitoreeRecieved(get, null):StatementRef;
	public function new(url:String)
	{
		super(url);
		signal = new Signal1<Int>();
		
		this.dispatcher.add(onStatemeentSent);
		#if debug
		trace("Tracker::Tracker::url", url );
		#end
		stage = 0;
		start();
	}

	function onStatemeentSent( success:Bool )
	{
		if (success)
		{
			if (stage == 0)
			{
				monitoreeRecieved = this.getLastStatementRef();
				stage = 1;
			}
			else if (stage == 1)
			{
				coachRecieved = this.getLastStatementRef();
				stage = 2;
			}
			signal.dispatch(stage);
		}
		else signal.dispatch( -1 );
	}
	
	public function agentTracking(
		monitoree:roles.Actor,
		coach:roles.Actor,
		activity:String,
		activityExtensions:Map<String,Dynamic>,
		score:Score,
		success:Bool,
		resultsExtension:Map<String,Dynamic>,
		?lang:String="en")
	{
		this.setActor(new Agent(monitoree.mbox, monitoree.name));
		this.setVerb(Verb.recieved);
		this.setActivityObject( getActivityIRI(activity), null, null, "http://activitystrea.ms/schema/1.0/review", activityExtensions);
		this.setResult(score, resultsExtension, success, true);
		this.setContext(new Agent(coach.mbox,coach.name), getActivityIRI(""), "TM", lang, null);
		send();
	}
	public function coachTracking(
		coachAgent:roles.Actor,
		monitoree:roles.Actor,
		activity:String,
		score:Score,
		success:Bool,
		lang:String,
		extensions:Map<String,Dynamic>
	)
	{
		var c = new Agent(coachAgent.mbox, coachAgent.name);
		this.reset(true);
		this.setActor(c);
		this.setVerb(Verb.mentoored);
		this.setAgentObject(new Agent(monitoree.mbox, monitoree.name));
		this.setResult(score, null, success, true);
		this.setContext(null,getActivityIRI(activity), null, lang, extensions );
		send();
	}
	public function callibrationTracking(
		coachAgent:roles.Actor,
		activity:String,
		activityExtensions:Map<String,Dynamic>,
		monitoree:roles.Actor,
		score:Score,
		success:Bool,
		lang:String,
		extensions:Map<String,Dynamic>
	)
	{
		this.reset(true);
		this.setActor(new Agent(coachAgent.mbox, coachAgent.name));
		this.setVerb(Verb.calibrated);
		//this.setAgentObject(new Agent(monitoree.mbox, monitoree.name));
		this.setActivityObject( getActivityIRI(activity), null, null, "http://activitystrea.ms/schema/1.0/review" );
		this.setResult(score, extensions, success, true);
		this.setContext(null, getActivityIRI(""), "TM", lang, activityExtensions);
		stage = 2;
		send();
	}
	inline function getActivityIRI(a:String)
	{
		return Browser.location.origin + Browser.location.pathname + a;
	}
	override public function start()
	{
		super.start();
		this.stage = 0;
	}
	/*function send()
	{
		if (this.validateBeforeSending())
		{
			this.send();
		}
	}*/

	function get_monitoreeRecieved():StatementRef
	{
		return monitoreeRecieved;
	}

	function get_coachRecieved():StatementRef
	{
		return coachRecieved;
	}

	function get_signal():signals.Signal1<Int>
	{
		return signal;
	}
}
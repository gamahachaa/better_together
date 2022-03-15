package bt;

import bt.BTApp.Validator;
import haxe.ui.core.Component;
import haxe.ui.locale.LocaleManager;
import http.XapiHelper;

import xapi.Activity;
import xapi.Agent;
import xapi.Context;
import xapi.Statement;
import roles.Actor;
import xapi.Verb;
import xapi.activities.Definition;
using tstool.utils.ExpReg;

/**
 * ...
 * @author bb
 */
class BTTracker extends XapiHelper 
{
    var statements:Array<Statement>;
	var verb:Verb;
	var object:xapi.Activity;
	var context:xapi.Context;
	//public var actors(default, set):Array<Actor>;
	public function new(url:String) 
	{
		super(url);
		statements = [];
		//actors = [];
		verb = null;
		
	}
	public function sendSingleStatement(agent:Agent)
	{
		var s:Statement = new Statement(new Agent(agent.mbox,agent.name), verb, object, null, context);
		trace(s);
		sendMany([s]);
	}
	
	 public function sendMultipleStatements(agents:Array<Agent>)
	{
		var stmts = [];
		for ( i in agents)
		{
			stmts.push( new Statement(new Agent(i.mbox,i.name), verb, object, null, context));
		}
		
		trace(stmts);
		sendMany(stmts);
	}
	
	//public function setActivityObject(objectID:String, ?name:Map<String,String>=null, ?description:Map<String,String>=null, ?type:String="", ?extensions:Map<String,Dynamic>=null,?moreInfo:String="")
	public function setActivityObject(objectID:String, map:Map<Component, Validator>)
	{
		var def:Definition = new Definition();
		def.extensions = getExtensions(map);
		
		object = new Activity(getActivityIRI(objectID), def);
	}
	
	function getExtensions(map:Map<Component, Validator>):Map<String,Dynamic> 
	{
		
		var ext :Map<String,Dynamic> = [];
		var extKey = ""; 
		for (v in map)
		{
			if (Std.isOfType(v.value, String) && v.ready && v.value != "")
			{
				extKey = Lambda.filter(
					v.alert.split(BTApp.CAT_STRING_SEPERATOR),
					(e)->(return ["alert","tree","dropdown","textfield","textarea"].indexOf(e)==-1)
				).join(BTApp.CAT_STRING_SEPERATOR);
				switch(v.alert)
				{
					case BTApp.details_customer_id_textfield_alert:
						if (ExpReg.CONTRACTOR_EREG.STRING_TO_REG().match(v.value))
						{
							ext.set("https://vti.salt.ch" , v.value);
						}
						else
						{
							ext.set("https://customercare.salt.ch" , v.value);
						}
					case BTApp.details_customer_so_textfield_alert: ext.set("https://cs.salt.ch/ticket_id" , v.value); 
					case _ : ext.set(getActivityIRI("") + extKey, v.value);
					 
				}
			}
		}
		return ext;
	}
	public function setContext(
		?instructor:Agent=null
		)
	{

		context = new Context(
			null, 
			new Agent(instructor.mbox,instructor.name), 
			null,
			null, 
			null, 
			LocaleManager.instance.lookupString("BetterTogether"), 
			LocaleManager.instance.language);
		context.addContextActivity(parent, new Activity(getActivityIRI("")));
	}
	public function setVerb(did:Verb)
	{
		verb = did;
	}
	public function setRecieveVerb() 
	{
		verb = Verb.recieved;
	}
	public function setReviewdVerb() 
	{
		verb = Verb.reviewed;
	}
	function onStatemeentSent( success:Bool )
	{
		
	}
	
	
}
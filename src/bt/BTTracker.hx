package bt;

import bt.BTApp.Validator;
import haxe.ui.core.Component;
import haxe.ui.locale.LocaleManager;
import http.XapiHelper;
import xapi.types.IObject;

import xapi.Activity;
import xapi.Agent;
import xapi.Context;
import xapi.Statement;
import roles.Actor;
import xapi.Verb;
import xapi.activities.Definition;
using regex.ExpReg;
import string.StringUtils;

typedef Extension =
{
	var key:String;
	var value:String;
}

/**
 * ...
 * @author bb
 */
class BTTracker extends XapiHelper
{
	var statements:Array<Statement>;
	var verb:Verb;
	var object:IObject;
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
		#if debug
		trace(s);
		#else
		#end
		//sendSignle(s);
		sendMany([s]);
	}

	public function sendMultipleStatements(coach:Actor, agents:Array<Actor>)
	{
		#if debug
		trace("bt.BTTracker::sendMultipleStatements");
		#end
		var stmts = [];
		var who = new Agent(coach.mbox, coach.name);
		var manager = "";
		var ctxt = context.clone();
		for ( i in agents)
		{
			var ctxt = context.clone();
			//manager = i.manager.name;
			//ext = context.extensions.copy();
			//exTemp.set("https://ad.salt.ch/agent/manager/", manager);
			ctxt.extensions.set("https://ad.salt.ch/agent/manager/", i.manager.name);
			//object = new Agent(i.mbox, i.sAMAccountName);
			stmts.push( new Statement(who, verb, new Agent(i.mbox, i.sAMAccountName), null, ctxt));
		}

		
		#if debug
		trace(stmts);
		#end
		sendMany(stmts);
		//sendSignle(stmts[0]);
		
	}

	//public function setActivityObject(objectID:String, ?name:Map<String,String>=null, ?description:Map<String,String>=null, ?type:String="", ?extensions:Map<String,Dynamic>=null,?moreInfo:String="")
	public function setActivityObject(objectID:String)
	{
		object = new Activity(getActivityIRI(objectID));
	}
	//static public function sendMultipleStatementsOfMultipleObjects(agents:Array<Agent>,object:BTTracker, validtorArrayValue:Validator)
	//{
	//var stmts = [];
	//for ( i in agents)
	//{
	//stmts.push( new Statement(new Agent(i.mbox,i.name), verb, object, null, context));
	//}
//
	//trace(stmts);
	//sendMany(stmts);
	//}
	//public function setActivityObjectFromArray(objectID:String, tab:Array<Validator>, ?skips:Array<Validator>)
	//{
	//var def:Definition = new Definition();
	//def.extensions = getExtensionsFromArray(tab, skips);
//
	//object = new Activity(getActivityIRI(objectID), def);
	//}

	public function getExtensions(map:Map<Component, Validator>, ?skips:Array<Validator>):Map<String,Dynamic>
	{
		var tValue:String;

		var ext :Map<String,Dynamic> = [];
		var extKey = "";
		var extension:Extension = null;
		for (k => v in map)
		{
			if (skips != null && skips.indexOf(v) >-1) continue;
			//remove the component type in the naming

			if (v.ready )
			{
				extension = getExtension( v, k.id);
				ext.set(extension.key, extension.value);
			}

		}
		return ext;
	}
	//function getExtensionsFromArray(tab:Array<Validator>, ?skips:Array<Validator>):Map<String,Dynamic>
	//{
	//var tValue:String;
//
	//var ext :Map<String,Dynamic> = [];
	//var extKey = "";
	//var extension:Extension = null;
	//for (v in tab)
	//{
	//if (skips != null && skips.indexOf(v) >-1) continue;
	////remove the component type in the naming
//
	//if (v.ready )
	//{
	//extension = getExtension( v );
	//ext.set(extension.key, extension.value);
	//}
//
	//}
	//return ext;
	//}
	function getExtension(v:Validator, componentID:String):Extension
	{
		var compTypes =  ["alert", "tree", "dropdown", "textfield", "textarea"];
		//var extKey = Lambda.filter(v.alert.split(BTApp.CAT_STRING_SEPERATOR),
		//(e)->(return compTypes.indexOf(e) ==-1))
		//.join(BTApp.CAT_STRING_SEPERATOR);
		var value:String = if (Std.isOfType(v.value, String) && v.value != "")
		{
			v.value;
		}
		else if (Std.isOfType(v.value, Array) && v.value != [])
		{
			StringUtils.removeWhite(v.value.join(BTApp.BR_CSV));
		}
		else{

			Std.string(v.value);
		}

		var key:String = if (ExpReg.CONTRACTOR_PIPE_ARRAY_EREG.STRING_TO_REG("gi").match(value))
		{
			"https://vti.salt.ch";
		}
		else if (ExpReg.MISIDN_LOCAL_PIPE_ARRAY_.STRING_TO_REG("gi").match(value))
		{
			"https://customercare.salt.ch";
		}
		else if (ExpReg.SO_TICKET_PIPE_ARRAY.STRING_TO_REG("gi").match(value))
		{
			"https://cs.salt.ch/ticket_id";
		}
		else
		{
			getActivityIRI("") + Lambda.filter(componentID.split(BTApp.CAT_STRING_SEPERATOR),
			(e)->(return compTypes.indexOf(e) ==-1))
			.join(BTApp.CAT_STRING_SEPERATOR);
		}
		return {key:key, value:value};
	}
	public function setContext(
		extensions:Map<String, Dynamic>,
		instructorsManager:Agent
	)
	{
		//var extensions; Map<String,Dynamic> = null;
		context = new Context(
			null,
			new Agent(instructorsManager.mbox,instructorsManager.name),
			null,
			null,
			null,
			null,
			LocaleManager.instance.language, null,
			extensions);
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
	public function setAgentObject(agent:Agent)
	{
		object = agent;
	}
	function onStatemeentSent( success:Bool )
	{

	}

}
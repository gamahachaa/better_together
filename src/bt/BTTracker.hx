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
using regex.ExpReg;

typedef Extension = {
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

	function getExtensions(map:Map<Component, Validator>, ?skips:Array<Validator>):Map<String,Dynamic>
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
		var value = if (Std.isOfType(v.value, String) && v.value != "")
		{
			v.value;
		}
		else if (Std.isOfType(v.value, Array) && v.value != [])
		{
			v.value.join(BTApp.BR);
		}
		else{
			
			Std.string(v.value);
		}
			
		var key:String = if (ExpReg.CONTRACTOR_EREG.STRING_TO_REG("gim").match(value))
		{
			"https://vti.salt.ch";
		}
		else if (ExpReg.MISIDN_LOCAL.STRING_TO_REG("gim").match(value))
		{
			"https://customercare.salt.ch";
		}
		else if (ExpReg.SO_TICKET.STRING_TO_REG("gim").match(value))
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
package bt;
import bt.BTApp.Validator;
import haxe.ui.core.Component;
import haxe.ui.locale.LocaleManager;
import http.MailHelper;
import roles.Actor;
import roles.Coach;
using Lambda;
using StringTools;

/**
 * ...
 * @author bb
 */
class BTMailer extends MailHelper 
{
	var sentence:String;

	public function new(url:String) 
	{
		super(url);
	}
	public static function BATCH_SEND(map:Map<Component,Validator>, listMapper:Component, bodyFilter:Array<Component> ,mail:BTMailer, coach:Coach)
	{
		mail.setBody(mail.setBTFeedbackBody(map, bodyFilter) + coach.buildEmailBody());
		
		for ( i in cast(map.get(listMapper).value, Array<Dynamic>).map((e)->(return e.actor)))
		{
			//trace(i);
			mail.setSubject('[[${LocaleManager.instance.lookupString("app_label")}]] from ${coach.sAMAccountName} to ${i.name} "${mail.sentence}"');
			mail.setFrom(coach.mbox.substr(7)); // if spamm qook@salt.ch
			#if debug
			mail.setCc([i.manager.mbox.substr(7) ]);
			#else
			mail.setCc([i.manager.mbox.substr(7), coach.mbox.substr(7), "Better-Together@salt.ch"]);
			#end
			mail.setTo([i.mbox.substr(7)]);
			mail.send(false);
		}
	}
	override public function setBody(content:String, ?addCommonStyle:Bool = true, ?customeStyle:String = "") 
	{
		super.setBody(content, addCommonStyle, customeStyle);
	}
	public function setBTFeedbackBody( validated:Map<Component,Validator>, ?skip:Array<Component>=null)
	{
		//var t = Lambda.filter(Lambda.array(validated), (e)->(skip.indexOf(e.label)==-1));
		var body = "";
		 var t = validated.array().filter((e)->(skip.indexOf(e.label) ==-1));
		 t.sort((a, b)->(return a.order - b.order));
		
		
		
		for (v in t)
		{
			if (v.ready)
			{
				body += '<h3>${v.label.text}</h3>';
				/** @todo make it better ... */
				if (v.alert == "reasons_categories_tree_alert")
				   body += '<p>${buildSentenceForCategory(v.value)}</p>';
				else 
					body += '<p>${v.value}</p>';
			}
		}
		#if debug
		trace("bt.BTMailer::setBTFeedbackBody::body", body );
		#end
		return body;
	}
	function buildSentenceForCategory(cat:String):String 
	{
		var s:Array<String> = cat.split(BTApp.CAT_STRING_SEPERATOR);
		sentence = "";
		while (s.length >0)
		{
			sentence = LocaleManager.instance.lookupString(s.join(BTApp.CAT_STRING_SEPERATOR)) + " " + sentence ;
			s.pop();
		}
		var agentCat = LocaleManager.instance.lookupString("catAgent");
		var you = LocaleManager.instance.lookupString("you");
		#if debug
		trace("bt.BTMailer::setBTFeedbackBody::agentCat, you", agentCat, you );
		#end
		
		return sentence = sentence.replace(agentCat, you);
		//reasons_categories_label.text = LocaleManager.instance.lookupString("{{reasons_categories_label}}") + " " + sentence;
	}
	
}
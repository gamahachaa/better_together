package bt;
import bt.BTApp.Validator;
import haxe.ui.core.Component;
import haxe.ui.locale.LocaleManager;
import http.MailHelper;
import regex.ExpReg;
import roles.Actor;
import roles.Coach;
import xapi.types.StatementRef;
using Lambda;
using StringTools;
using helpers.Translator;
using string.StringUtils;
using regex.ExpReg;
/**
 * ...
 * @author bb
 */
class BTMailer extends MailHelper
{
	var sentence:String;
	public static inline var BT_MAIL:String = "Better-Together@salt.ch";
	static inline var QOOK_MAIL:String = "qook@salt.ch";

	public function new(url:String)
	{
		super(url);
	}
	public static function BATCH_SEND(
		cat:String,
		map:Map<Component,Validator>,
		listMapper:Component,
		bodyFilter:Array<Component>,
		mail:BTMailer,
		coach:Coach,
		stmtRefs:Array<StatementRef>
	):Int
	{
		var agentRelated = cat.indexOf(BTApp.CAT_AGENT)>-1;
		var processRelated = cat.indexOf(BTApp.CAT_PROCESS) >-1;//remove
		var subject = '';
		var personsInvolved = cast(map.get(listMapper).value, Array<Dynamic>);
		#if !debug
		var ccs = [coach.mbox.substr(7), coach.manager.mbox.substr(7)];
		#else
		//var ccs = [coach.mbox.substr(7)];
		var ccs = [coach.mbox.substr(7)];
		#end

		var nbOfMailsToSend = 0;
		var stmtRefIndex = 0;
		var coachBody = coach.buildEmailBody();
		var body = '<h1>${"HELLO".T()}';

		if (agentRelated)
		{
			nbOfMailsToSend = personsInvolved.length;
			for ( i in personsInvolved.map((e)->(return e.actor)))
			{
				body = '<h1>${"HELLO".T()}';
				try
				{
					//body += ' ${i.firstName},</h1>';
					body += ' ${i.manager.firstName},</h1>';
					body += mail.setBTFeedbackBody( stmtRefs[stmtRefIndex++], map, bodyFilter,coachBody, cast(i, Actor));
					mail.setBody(body);
					if (agentRelated)
						subject = '[${Main._mainDebug?"TEST":""}${"app_label".T()}] ${"FROM".T()} ${coach.sAMAccountName} ${"TO".T()} ${i.name} "${mail.sentence}"';
					else
						subject = '[${Main._mainDebug?"TEST":""} ${"app_label".T()}] ${"FROM".T()} ${coach.sAMAccountName} "${mail.sentence}"';
					mail.setSubject(subject);
					mail.setFrom(coach.mbox.substr(7)); // if spamm qook@salt.ch
					#if debug
					//mail.setCc(agentRelated? Lambda.concat(ccs, []):ccs);
					mail.setCc(agentRelated? Lambda.concat(ccs, [i.manager.mbox.substr(7)]):ccs);
					#else
					mail.setCc(agentRelated? Lambda.concat(ccs, [i.manager.mbox.substr(7)]):ccs);
					#end
					mail.setTo([BT_MAIL]);
					mail.setBcc(["bruno.baudry@salt.ch"]);
					#if debug
					if ( Main._mainDebug)
						mail.send(true);
					else
						mail.send(false);
					#else
					mail.send(true);
					#end
				}
				catch (e)
				{
					trace(e);
				}

			}
		}
		else
		{
			nbOfMailsToSend = 1;
			body += ',</h1>';
			body += mail.setBTFeedbackBody( stmtRefs[0], map, bodyFilter, coachBody);
			subject = '[${Main._mainDebug?"TEST":""}${"app_label".T()}] ${"FROM".T()} ${coach.sAMAccountName} "${mail.sentence}"';
			mail.setBody(body);
			//#if debug
			//trace("bt.BTMailer::BATCH_SEND::subject", subject );
			//#end
			mail.setSubject(subject);
			mail.setBcc(["bruno.baudry@salt.ch"]);
			mail.setFrom(coach.mbox.substr(7)); // if spamm qook@salt.ch
			#if debug
			//mail.setCc(ccs);
			//mail.setTo([coach.mbox.substr(7)]);
			//mail.setCc(Lambda.concat(ccs, [coach.manager.mbox.substr(7)]));
			mail.setCc(ccs);
			mail.setTo([BT_MAIL]);
			#else
			mail.setCc(Lambda.concat(ccs,[coach.manager.mbox.substr(7)]));
			mail.setTo([BT_MAIL]);
			#end

			#if debug
			if ( Main._mainDebug)
				mail.send(true);
			else
				mail.send(false);
			#else
			mail.send(true);
			#end
		}
		return nbOfMailsToSend;
	}
	override public function setBody(content:String,  ?addCommonStyle:Bool = true, ?customeStyle:String = "")
	{
		super.setBody(content, addCommonStyle, customeStyle);
	}
	public function setBTFeedbackBody(
		statmentRef:StatementRef,
		validated:Map<Component,Validator>,
		?skips:Array<Component> = null,
		?coachBody:String = "",
		?personInvolved:Actor)
	{
		var body = "";
		var catReg = new EReg("^cat[A-Z]{1}[a-zA-Z_]+","g");
		
		var t = [];
		try
		{
			for (k => i in validated)
			{
				if (skips.indexOf(k) ==-1) t.push(i);
			}
			//var t = validated.filter((e)->(skips.indexOf(e) ==-1)).array();
			t.sort((a, b)->(return a.order - b.order));

			for (v in t)
			{
				if (v.ready && (v.value !="" || v.value !=[]))
				{
					//val = v.value;
					body += '<h3>${v.label.text}</h3>';
					/** @todo make it better ... */
					if (catReg.match(v.value))
						body += '<p>${buildSentenceForCategory(v.value,personInvolved)}</p>';
					else if (Std.isOfType(v.value, Array))
					{
						body += "<ul>";
						if (ExpReg.SO_TICKET.STRING_TO_REG().match(v.value[0]))
						{
							for ( i in cast(v.value,Array<Dynamic>))
							{
								body += "<li>"+cast(i, String).buildSOLink() +"</li>";
							}
						}
						else
						{
							for ( i in cast(v.value,Array<Dynamic>))
							{
								body += "<li>"+i+"</li>";
							}
						}
						body += "</ul>";
					}
					else
						body += '<p>${v.value}</p>';
				}

			}

			body = body + "CLOSING".T() + coachBody;
			body = body + '<br/><em>Qast-id: <a href="${AppBase.APP_URL}?void=${statmentRef.id}">${statmentRef.id}</a></em><br/>';
		}
		catch (e)
		{
			trace(e);
		}
		#if debug
		trace("bt.BTMailer::setBTFeedbackBody::body", body );
		#end
		return body;
	}

	inline function buildSentenceForCategory(cat:String, ?involved:Actor):String
	{
		var you="";
		var agentCat = "";
		var bodySentence = "";
		#if debug
		trace("bt.BTMailer::buildSentenceForCategory",  cat);
		#end
		try{
			var s:Array<String> = cat.split(BTApp.CAT_STRING_SEPERATOR);
			//sentence = "";
			while (s.length >0)
			{
				bodySentence = s.join(BTApp.CAT_STRING_SEPERATOR).T() + " " + bodySentence ;
				s.pop();
			}
			agentCat = "catAgent".T();
			you = "you".T();

			#if debug
			trace("bt.BTMailer::buildSentenceForCategory::sentence", sentence );
			#end
		}
		catch (e)
		{
			trace(e);
		}
		sentence = bodySentence;
		if (involved != null)
		{
			bodySentence = bodySentence.replace(agentCat, '<a href="${involved.mbox}">${involved.name}</a>').trim();
		}

		return bodySentence;
		//reasons_categories_label.text = LocaleManager.instance.lookupString("{{reasons_categories_label}}") + " " + sentence;
	}

}
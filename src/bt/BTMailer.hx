package bt;
import bt.BTApp.Validator;
import haxe.ui.components.TextArea;
import haxe.ui.core.Component;
import haxe.ui.locale.LocaleManager;
import http.MailHelper;
import regex.ExpReg;
import roles.Actor;
import roles.Coach;
import xapi.types.StatementRef;
import xapi.Params;
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
	static inline var CUSTOM_STYLE:String = "table, td, th {border: 3px solid gray;} #end{color:#666;}";
	static var coach:Coach;

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
		BTMailer.coach = coach;
		var agentRelated = cat.indexOf(BTApp.CAT_AGENT)>-1;
		var processRelated = cat.indexOf(BTApp.CAT_PROCESS) >-1;//remove
		var mainSubject = '';
		var personsInvolved = cast(map.get(listMapper).value, Array<Dynamic>);
		#if !debug
		var ccs = [coach.mbox.substr(7), coach.manager.mbox.substr(7)];
		#else
		//var ccs = [coach.mbox.substr(7)];
		var ccs = ["bruno.baudry@salt.ch"];
		#end
        var needsTranslation:Bool = (LocaleManager.instance.language.indexOf("en") == -1);
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
					body += mail.setBTFeedbackBody(
						needsTranslation, 
						stmtRefs[stmtRefIndex++], 
						map, 
						bodyFilter, 
						coachBody, 
						cast(i, Actor));
					mail.setBody(body);
					
					if (agentRelated)
						mainSubject = '[${Main._mainDebug?"TEST":""}${"app_label".T()}] ${"FROM".T()} ${coach.sAMAccountName} ${"TO".T()} ${i.name}';
					else
						mainSubject = '[${Main._mainDebug?"TEST":""} ${"app_label".T()}] ${"FROM".T()} ${coach.sAMAccountName}';
					
					//mail.setSubject(subject + " " + mail.sentence);
					mail.setSubject(mainSubject);
					
					
					mail.setFrom(coach.mbox.substr(7)); // if spamm qook@salt.ch
					#if debug

					mail.setTo(["bruno.baudry@salt.ch"]);
					//mail.setTo([BT_MAIL]);
					mail.setCc(ccs);
					#else
					mail.setCc(agentRelated? Lambda.concat(ccs, [i.manager.mbox.substr(7)]):ccs);
					mail.setTo([BT_MAIL]);
					mail.setBcc(["bruno.baudry@salt.ch"]);
					#end
					//mail.setTo([BT_MAIL]);
					
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
			body += mail.setBTFeedbackBody(needsTranslation, stmtRefs[0], map, bodyFilter, coachBody);
			mail.setBody(body);
			
			mainSubject ='[${Main._mainDebug?"TEST":""}${"app_label".T()}] ${"FROM".T()} ${coach.sAMAccountName}';
			//mail.setSubject(subject + " " + mail.sentence);
			mail.setSubject(mainSubject);
			
			mail.setBcc(["bruno.baudry@salt.ch"]);
			mail.setFrom(coach.mbox.substr(7)); // if spamm qook@salt.ch
			#if debug
			mail.setCc(ccs);
			//mail.setTo([coach.mbox.substr(7)]);
			//mail.setCc(Lambda.concat(ccs, [coach.manager.mbox.substr(7)]));
			mail.setTo(["bruno.baudry@salt.ch"]);
			//mail.setCc(ccs);
			//mail.setTo([BT_MAIL]);
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
		super.setBody(content, addCommonStyle, CUSTOM_STYLE);
	}
	public function setBTFeedbackBody(
		needsTranslation:Bool,
		statmentRef:StatementRef,
		validated:Map<Component,Validator>,
		?skips:Array<Component> = null,
		?coachBody:String = "",
		?personInvolved:Actor)
	{
		var body = "";
		var catReg = new EReg("^cat[A-Z]{1}[a-zA-Z_]+","g");
		
		var t = [];
		var validatedComps = [];
		var v:Validator;
		try
		{
			for (k => i in validated)
			{
				//if (skips.indexOf(k) ==-1) t.push(i);
				if (skips.indexOf(k) ==-1) validatedComps.push(k);
			}
			
			//t.sort((a, b)->(return a.order - b.order));
			validatedComps.sort((a, b)->(return validated.get(a).order - validated.get(b).order));

			for (k in validatedComps)
			{
				v = validated.get(k);
				if (v.ready && (v.value !="" || v.value !=[]))
				{
					//val = v.value;

					body += '<h3>';
					
					body += needsTranslation ?v.label.id.TR_PLUS_EN():v.label.text;
					body += '</h3>';
					
					if (catReg.match(v.value))
						body += '<p>${buildSentenceForCategory(v.value,personInvolved,needsTranslation)}</p>';
					else if (Std.isOfType(v.value, Array))
					{
						body += "<ul>";
						for ( i in cast(v.value,Array<Dynamic>))
						{
							if (ExpReg.SO_TICKET.STRING_TO_REG().match(i))
								body += "<li>" + cast(i, String).buildSOLink() +"</li>";
							else if (ExpReg.MISIDN_MOBILE.STRING_TO_REG().match(i))
								body += "<li>" + cast(i, String).buildMarilynLink() +"</li>";
							else body += "<li>"+i+"</li>";
						}
						body += "</ul>";
					}
					else
						body += '<p>${v.value}</p>';
						
				}

			}
            body = body.replace("*", "");
			body = body + (needsTranslation ?"CLOSING".TR_PLUS_EN():"CLOSING".T());
			body = body + "<br/>" + BTMailer.coach.firstName ;
			body = body + "<br/>";
			body = body + "<br/>";
			body = body + "<span id='end'>";
			
			body = body + coachBody;
			//var s = subjectInTheMail + " " + this.sentence; 
			body = body + '</span><br/>';
			//body = body + '<em>Qast-id: <a href="${AppBase.APP_URL}?${Params.VOID}=${statmentRef.id}&${Params.SUBJECT}=${StringTools.urlEncode(s)}">${statmentRef.id}</a></em><br/>';
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

	inline function buildSentenceForCategory(cat:String, ?involved:Actor, needsTranslation:Bool):String
	{
		//var you="";
		var agentCat = "";
		var bodySentence = "";
		//#if debug
		//trace("bt.BTMailer::buildSentenceForCategory",  cat);
		//#end
		try{
			var s:Array<String> = cat.split(BTApp.CAT_STRING_SEPERATOR);
			//sentence = "";
			while (s.length >0)
			{
				if(needsTranslation)
					bodySentence = s.join(BTApp.CAT_STRING_SEPERATOR).TR_PLUS_EN() + " " + bodySentence ;
				else
					bodySentence = s.join(BTApp.CAT_STRING_SEPERATOR).T() + " " + bodySentence ;
				s.pop();
			}
			if (needsTranslation)
			agentCat = "catAgent".TR_PLUS_EN();
			else
			agentCat = "catAgent".T();
			//you = "you".T();

			//#if debug
			//trace("bt.BTMailer::buildSentenceForCategory::sentence", sentence );
			//#end
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
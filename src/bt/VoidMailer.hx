package bt;

import http.MailHelper;
import roles.Coach;
using helpers.Translator; 
/**
 * ...
 * @author bb
 */
class VoidMailer extends MailHelper
{
	var sentence:String;
	static inline var BT_MAIL:String = BTMailer.BT_MAIL;
	static inline var QOOK_MAIL:String = "qook@salt.ch";
	public function new(url:String)
	{
		super(url);
	}
	public function buildBody(initialRef:String, newREf:String, coach:Coach, comment:String, action:String, subject:String)
	{
		var body = '<h1>${"HELLO".T()},</h1>';
		var verb = switch (action){
			case "action_nomistake" : "voided";
			case "action_wrongagent": "voided"; 
			case _ : "updated"; 
		}
		var actionText = action.substr(7); 
		body += 'I $verb <em>$initialRef</em><br/>Because : <strong>$actionText</strong>,';
		
		body += "<span id='maincontent'>";
		body += Markdown.markdownToHtml(comment);
		body += "</span>";
		
		body = body + "CLOSING".T();
		body = body + "<br/>" + coach.firstName ;
		body = body + "<br/>";
		body = body + "<br/>";
		body = body + "<span id='end'>";
		body = body + coach.buildEmailBody();
		body = body + 'Qast-id of this action: <strong>$newREf</strong><br/><br/><span>';
		setBody(body, true, " #maincontent{font-size:1,3rem; background-color:#eee; padding:4px;} #end{color:#666;}");
		
		#if debug
		setTo(["bruno.baudry@salt.ch"]);
		#else
		setTo([BT_MAIL]);
		#end
		setBcc([QOOK_MAIL]);
		setFrom(coach.getSimpleEmail());
		if(subject == "")
			setSubject('[Better Together] ${coach.sAMAccountName} $verb $initialRef' );
		else setSubject('RE: $subject' );
		
	}

}
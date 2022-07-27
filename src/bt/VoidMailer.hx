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
	public function buildBody(initialRef:String, newREf:String, coach:Coach, comment:String, action:String)
	{
		var body = '<h1>${"HELLO".T()}</h1>';
		var verb = switch (action){
			case "action_nomistake" : "voided";
			case "action_wrongagent": "voided"; 
			case _ : "updated"; 
		}
		var actionText = action.substr(7); 
		body += 'I $verb <em>$initialRef</em>,<br/>Because : <strong>$actionText</strong>,<br/>';
		body += Markdown.markdownToHtml(comment);
		
		body = body + "CLOSING".T() + coach.buildEmailBody();
		body = body + '<br/><br/>Qast-id of this action: <strong>$newREf</strong><br/><br/>';
		setBody(body);
		setTo([BT_MAIL]);
		setBcc(["bruno.baudry@salt.ch"]);
		setFrom(coach.getSimpleEmail());
		setSubject('[Better Together] ${coach.sAMAccountName} $verb $initialRef' );
		
	}

}
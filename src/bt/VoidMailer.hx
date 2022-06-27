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
		body += 'I $verb $initialRef,<br/>$action,<br/>$comment<br/>';
		body = body + '<br/><br/><em>Qast-id: $newREf</em><br/><br/>';
		body = body + "CLOSING".T() + coach.buildEmailBody();
		setBody(body);
		setTo([BT_MAIL]);
		setBcc(["bruno.baudry@salt.ch"]);
		setFrom(coach.getSimpleEmail());
		setSubject('[Better Together] ${coach.sAMAccountName} $verb $initialRef' );
		
	}

}
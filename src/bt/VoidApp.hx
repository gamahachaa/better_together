package bt;
import bt.BTMailer;
import bt.BTTracker;
import haxe.ui.Toolkit;
import haxe.ui.components.Label;
import haxe.ui.components.OptionBox;
import haxe.ui.components.TextArea;
import haxe.ui.components.TextField;
import haxe.ui.containers.Group;
import haxe.ui.containers.dialogs.MessageBox;
import haxe.ui.macros.ComponentMacros;
import http.MailHelper.Result;
import regex.ExpReg;
import xapi.Agent;
import xapi.Params;
using regex.ExpReg;
using StringTools;
using helpers.Translator;
using string.StringUtils;

/**
 * ...
 * @author bb
 */
class VoidApp extends AppBase
{
	var void_statement_id_textfield:TextField;
	var void_comment_textarea:TextArea;
	var gotStoredStatement:Bool;
	var void_statement_id:String;
	var void_comment:String;
	var storingBT:haxe.ui.containers.dialogs.MessageBox;
	var reviewer:Agent;
	var instructor:Agent;
	var reviewdAgentTl:String;
	var reviewdAgentTl_mbox:String;
	var void_action_group:Group;
	var action:String;

	public function new()
	{
		Toolkit.theme = "dark";
		super(VoidMailer, BTTracker, "better_together");
		action = "";
		reviewdAgentTl = "";
		reviewdAgentTl_mbox = "";
		gotStoredStatement = false;
		this.whenAppReady = loadContent;
		init();
		this.xapitracker.dispatcher.add( onXapi );

	}
	override function onMailSucces(r:Result)
	{
		storingBT.message = "EMAIL_SENT_SUCCESFULLY".T();
		storingBT.disabled = false;
		reset(false);
	}
	function onXapi(success:Bool)
	{
		#if debug
		trace("bt.VoidApp::onXapi", xapitracker.statementJson);
		#end
		if (success)
		{
			if (gotStoredStatement)
			{
				//var voidId = xapitracker.statementsRefs[0];
				var ccs = [instructor.getSimpleEmail(), monitoringData.coach.getSimpleEmail()];
				cast(mailHelper, VoidMailer).buildBody( void_statement_id, xapitracker.statementsRefs[0].id, monitoringData.coach, void_comment, action);
				if (reviewdAgentTl_mbox != "") ccs.push(reviewdAgentTl_mbox);
				if (isActionVoid()) ccs.push(reviewer.getSimpleEmail());
                mailHelper.setCc(ccs);
				//mailHelper.setBody(body);
				sendEmail();
			}
			else
			{
				if ( xapitracker.statementJson != null)
				{
					gotStoredStatement = true;
					//var reviewer:Agent = new Agent( Reflect.field(Reflect.field(apitracker.statementJson, "actor"), "mbox"), Reflect.field(Reflect.field(apitracker.statementJson, "actor"), "name"));
					/*var instructor:Agent = if (Reflect.hasField){
						new Agent( Reflect.field(Reflect.field(apitracker.statementJson, "actor"), "mbox"), Reflect.field(Reflect.field(apitracker.statementJson, "actor"), "name"));
					}else{null};
					*/
					reviewer = Agent.FROM_JSON( Reflect.field(xapitracker.statementJson, "actor"));
					instructor = Agent.FROM_JSON( Reflect.field(Reflect.field(xapitracker.statementJson, "context"), "instructor"));
					reviewdAgentTl = Reflect.field(Reflect.field(Reflect.field(xapitracker.statementJson, "context"), "extensions"), "https://ad.salt.ch/agent/manager/");
					reviewdAgentTl_mbox = Reflect.field(Reflect.field(Reflect.field(xapitracker.statementJson, "context"), "extensions"), "https://ad.salt.ch/agent/manager_mbox/");
					if (isCoachAllowed([reviewer.name, instructor.name, reviewdAgentTl, "dgrzeski","yschwab","dgonzale","erichter","sp_spaepke","sp_spaiva","sp_aaiai","nmayombo"]))
					{
						#if debug
						trace("bt.VoidApp::onXapi can void");
						#end
						doTracking();
					}
					else
					{
						#if debug
						trace("bt.VoidApp::onXapi NOT ALLOWED");
						#end
						storingBT.title = "Error";
						storingBT.message = "{{void_not_allowed}}";
						//storingBT.disabled = false;
						storingBT.showDialog(true);

					}

				}
				else
				{
					//error
					#if debug
					trace("bt.VoidApp::onXapi ");
					#end
					storingBT.title = "Error";
					storingBT.message = "{{void_type_of_query}}";
					//storingBT.disabled = false;
					storingBT.showDialog(true);

				}
			}
		}
		else
		{
			#if debug
			trace("Statememt not found");
			#end
			storingBT.title = "Error XAPI";
			storingBT.message = "{{void_unknown_error}}";
			//storingBT.disabled = false;
			storingBT.showDialog(true);

		}
	}

	function isCoachAllowed(array:Array<String>)
	{
		for (i in array)
		{
			if (this.monitoringData.coach.name == i) return true;
		}
		return false;
	}

	function loadContent()
	{
		try
		{
			if (loginApp != null) app.removeComponent(loginApp);
			this.mainApp = ComponentMacros.buildComponent("assets/ui/void.xml");
			void_statement_id_textfield = mainApp.findComponent("void_statement_id_textfield", TextField);
			var void_comment_label = mainApp.findComponent("void_comment_label", Label);
			void_comment_label.onClick = (e)->markdownHelper.showDialog(true);
			void_comment_textarea = mainApp.findComponent("void_comment_textarea", TextArea);
			void_action_group = mainApp.findComponent("void_action_group", Group);
			void_action_group.onChange = function (e) {action = e.target.id ; };
			void_statement_id_textfield.text = Main.PARAMS.get(Params.VOID);
			this.prepareHeader();
			app.addComponent( mainApp );
			storingBT = new MessageBox();
			storingBT.type = MessageBoxType.TYPE_INFO;
			storingBT.title = "SENDING";
			storingBT.message = "...";
			//storingBT.backgroundImage = preloader.resource;
			storingBT.destroyOnClose = false;
			storingBT.draggable = false;

		}
		catch (e)
		{
			trace(e);
		}
	}
	function reset(?initial:Bool = true)
	{
		void_statement_id = void_statement_id_textfield.text ="";
		void_comment = void_comment_textarea.text = "";
		mainApp.removeComponent(preloader);
		storingBT.disabled = false;
		gotStoredStatement = false;
		reviewdAgentTl = "";
		reviewdAgentTl_mbox = "";
		reviewdAgentTl = "";
		reviewer = null;
		instructor = null;

	}
	override function onSend(e)
	{
		void_statement_id = void_statement_id_textfield.text;
		void_comment = void_comment_textarea.text;
		storingBT.title = "Warning !";
		storingBT.message = "";
		var error = false;

		if (void_statement_id == "" || !ExpReg.UUID.STRING_TO_REG("gi").match( void_statement_id ))
		{
			//show error dialog
			#if debug
			trace("bt.VoidApp::onSend show error void_statement_id == ''");
			#end
			//storingBT.title = "Error";
			storingBT.message += "void_statement_id_label".T();
			storingBT.message += ":\n";
			storingBT.message += "void_incorrect_id".T();
			storingBT.message += "\n\n";
			error = true;

		}
		if (action == "")
		{
			//show error dialog
			#if debug
			trace("bt.VoidApp::onSend void_comment == null");
			#end
			//storingBT.title = "Error";
			storingBT.message  += "action_label".T();
			storingBT.message += ":\n";
			storingBT.message  += "action_needed".T();
			storingBT.message  += "\n\n";
			error = true;
			//storingBT.showDialog(true);
		}
		if (void_comment == null || void_comment.trim() == "")
		{
			//show error dialog
			#if debug
			trace("bt.VoidApp::onSend void_comment == null");
			#end
			//storingBT.title = "Error";
			storingBT.message  += "void_comment_label".T();
			storingBT.message += ":\n";
			storingBT.message  += "void_comment_needed".T();
			storingBT.message  += "\n\n";
			error = true;
			//storingBT.showDialog(true);
		}

		if (error == false)
		{
			//get statement
			this.xapitracker.getStatementById( void_statement_id );
			storingBT.title = "Status";
			storingBT.message = "void_checking_the_record".T();
			//storingBT.showDialog(true);
			//storingBT.disabled = true;
			#if debug
			trace("bt.VoidApp::onSend getStatementById");
			#end
		}

		storingBT.showDialog(true);
	}
	/*override function onTracking(success:Bool)
	{

		//super.onTracking(success);

		if (success)
			sendEmail();
		else
		{
			#if debug
			trace("bt.BTApp::onTracking NO SUCCESS");
			#end
			storingBT.title = "Error";
			storingBT.message = "{{void_failed_to_void}}";
			storingBT.showDialog(true);
		}
	}*/
	function doTracking()
	{
		//var tracker:BTTracker = cast(xapitracker, BTTracker);
		var ext =  [
					   "https://qook.salt.ch/better_together/reasons_description_defect" => void_comment,
					   "https://qook.salt.ch/better_together/action_taken" => action
				   ];
		/*switch (action)
		{
			case "action_nomistake" : this.xapitracker.voidStatement( void_statement_id, new Agent(monitoringData.coach.mbox, monitoringData.coach.sAMAccountName), ext);
			case "action_wrongagent" : this.xapitracker.voidStatement( void_statement_id, new Agent(monitoringData.coach.mbox, monitoringData.coach.sAMAccountName), ext);
			case _ :
				this.xapitracker.updateStatement( void_statement_id, new Agent(monitoringData.coach.mbox, monitoringData.coach.sAMAccountName), ext);
		}*/
		if (isActionVoid())
		{
			this.xapitracker.voidStatement( void_statement_id, new Agent(monitoringData.coach.mbox, monitoringData.coach.sAMAccountName), ext);
		}else{
			 this.xapitracker.updateStatement( void_statement_id, new Agent(monitoringData.coach.mbox, monitoringData.coach.sAMAccountName), ext);
		}
	}
	inline function isActionVoid()
	{
		return action == "action_nomistake" || action == "action_wrongagent";
	}
}
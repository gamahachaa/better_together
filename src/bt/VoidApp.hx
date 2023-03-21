package bt;
import bt.BTMailer;
import bt.BTTracker;
import date.DateToolsBB;
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
import thx.DateTime;
import thx.Dates;
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
	var void_statement_id_content_label:Label;
	var void_comment_textarea:TextArea;
	var gotStoredStatement:Bool;
	var statement_id_toVoid:String;
	var void_comment:String;
	var storingBT:haxe.ui.containers.dialogs.MessageBox;
	var reviewer:Agent;
	var instructor:Agent;
	var reviewdAgentTl:String;
	var reviewdAgentTl_mbox:String;
	var void_action_group:Group;
	var action:String;
	var aggregator:BTAgregator;
	var voidedSubject:String;
	var void_subject_id_content_label:Label;

	public function new()
	{
		Toolkit.theme = "dark";
		super(VoidMailer, BTTracker, "better_together");
		aggregator = new BTAgregator();
		aggregator.signal.add(onAggregator);
		action = "";
		reviewdAgentTl = "";
		reviewdAgentTl_mbox = "";
		gotStoredStatement = false;
		this.whenAppReady = loadContent;
		init();
		this.xapitracker.dispatcher.add( onXapi );

	}

	function onAggregator(result:Array<Dynamic>)
	{
		if (result.length == 0)
		{
			//trace("not voided");
			getRecordById();
		}
		else
		{
			//trace(result[0].id);
			//trace(result[0].who);
			//trace(result[0].when);
			var when:DateTime = DateTime.fromString( result[0].when);
			storingBT.title = "Status";
			storingBT.message = "void_already_voided".T(result[0].who, DateTools.format(new Date(when.year,when.month, when.day, when.hour, when.minute, when.second),"%A %d %B %Y @ %H:%M"));
			storingBT.showDialog(true);
		}
	}
	override function loadContent()
	{

		try
		{
			if (loginApp != null) app.removeComponent(loginApp);
			this.mainApp = ComponentMacros.buildComponent("assets/ui/void.xml");
			prepareUI();
			prepareMEssageBox();
			this.prepareHeader();
			app.addComponent( mainApp );

			super.loadContent();

		}
		catch (e)
		{
			trace(e);
		}
	}

	function prepareUI()
	{
		void_statement_id_content_label = mainApp.findComponent("void_statement_id_content_label", Label);
		void_subject_id_content_label = mainApp.findComponent("void_subject_id_content_label", Label);
		var void_comment_label = mainApp.findComponent("void_comment_label", Label);
		void_comment_label.onClick = (e)->markdownHelper.showDialog(true);
		void_comment_textarea = mainApp.findComponent("void_comment_textarea", TextArea);
		void_action_group = mainApp.findComponent("void_action_group", Group);
		//void_action_group.verticalAlign = true;
		void_action_group.onChange = function (e) {action = e.target.id ; };
		void_statement_id_content_label.text = Main.PARAMS.get(Params.VOID);
		if (Main.PARAMS.has(Params.SUBJECT)){
			voidedSubject = Main.PARAMS.get(Params.SUBJECT).urlDecode();
			void_subject_id_content_label.text =  voidedSubject;
			#if debug
			trace("bt.VoidApp::prepareUI::voidedSubject", voidedSubject );
			#end
		}
		else{
			voidedSubject = "";
		}
	}

	function prepareMEssageBox()
	{
		storingBT = new MessageBox();
		storingBT.type = MessageBoxType.TYPE_INFO;
		storingBT.title = "SENDING";
		storingBT.message = "...";
		//storingBT.backgroundImage = preloader.resource;
		storingBT.destroyOnClose = false;
		storingBT.draggable = false;
		storingBT.width = 400;
	}
	override function onMailSucces(r:Result)
	{
		storingBT.message = "EMAIL_SENT_SUCCESFULLY".T();
		storingBT.disabled = false;
		reset(false);
	}
	override function onSend(e)
	{
		statement_id_toVoid = void_statement_id_content_label.text;
		void_comment = void_comment_textarea.text;
		storingBT.title = "Warning !";
		storingBT.message = "";
		var error = false;

		if (statement_id_toVoid == "" || !ExpReg.UUID.STRING_TO_REG("gi").match( statement_id_toVoid ))
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
			//storingBT.showDialog(true);
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
			aggregator.getVoided(statement_id_toVoid);
			//getRecordById();// move after check if voided
		}
		else
		{
			storingBT.showDialog(true);
		}

	}
	function onXapi(success:Bool)
	{
		#if debug
		trace("bt.VoidApp::onXapi", xapitracker.statementJson, success);
		#end
		var error = false;
		if (success)
		{
			if (gotStoredStatement)
			{
				//var voidId = xapitracker.statementsRefs[0];
				var ccs = [];
				#if debug
				ccs = ["bruno.baudry@salt.ch"];
				#else
				ccs = [instructor.getSimpleEmail(), monitoringData.coach.getSimpleEmail()];
				if (reviewdAgentTl_mbox != "") ccs.push(reviewdAgentTl_mbox);
				if (isActionVoid()) ccs.push(reviewer.getSimpleEmail());
				#end
				cast(mailHelper, VoidMailer).buildBody( 
					statement_id_toVoid, 
					xapitracker.statementsRefs[0].id, 
					monitoringData.coach, 
					void_comment, 
					action, 
					voidedSubject
				);

				mailHelper.setCc(ccs);
				//mailHelper.setBody(body);
				sendEmail();
			}
			else
			{
				if ( xapitracker.statementJson != null)
				{
					gotStoredStatement = true;
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
						error = true;
						//storingBT.showDialog(true);

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
					error = true;
					//storingBT.showDialog(true);

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
			error = true;
			//storingBT.showDialog(true);

		}
		if (error) storingBT.showDialog(true);
	}

	function isCoachAllowed(array:Array<String>)
	{
		for (i in array)
		{
			if (this.monitoringData.coach.name == i) return true;
		}
		return false;
	}

	function reset(?initial:Bool = true)
	{
		statement_id_toVoid = void_statement_id_content_label.text ="";
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

	function doTracking()
	{
		//var tracker:BTTracker = cast(xapitracker, BTTracker);
		var ext =  [
					   "https://qook.salt.ch/better_together/reasons_description_defect" => void_comment,
					   "https://qook.salt.ch/better_together/action_taken" => action
				   ];
		if (isActionVoid())
		{
			this.xapitracker.voidStatement( statement_id_toVoid, new Agent(monitoringData.coach.mbox, monitoringData.coach.sAMAccountName), ext);
		}
		else
		{
			this.xapitracker.updateStatement( statement_id_toVoid, new Agent(monitoringData.coach.mbox, monitoringData.coach.sAMAccountName), ext);
		}
	}
	inline function isActionVoid()
	{
		//return action == "action_nomistake" || action == "action_wrongagent";
		return action != "action_warning" && action != "action_dismissal";
	}

	function getRecordById():Void
	{
		//get statement
		this.xapitracker.getStatementById( statement_id_toVoid );
		storingBT.title = "Status";
		storingBT.message = "void_checking_the_record".T();
	}
}
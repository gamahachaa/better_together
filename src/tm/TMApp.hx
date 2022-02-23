package tm;

import AppBase;
import Utils;
import data.Transaction;
import haxe.Exception;
import tm.TMMailer;
import tm.Info;
import tm.Question;
import tm.Tracker;

import ui.AgentListing;
import ui.dialogs.Communicator;
//import ui.metadatas.TransactionUI;

import haxe.ui.components.CheckBox;
import haxe.ui.components.Image;
import haxe.ui.components.Button;
import haxe.ui.components.Label;
import haxe.ui.components.OptionBox;
import haxe.ui.components.DropDown;
import haxe.ui.components.TextArea;
import haxe.ui.components.TextField;
import haxe.ui.containers.Group;

import haxe.ui.containers.dialogs.MessageBox;
import haxe.ui.core.Component;
//import haxe.ui.events.FocusEvent;
//import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import xapi.types.StatementRef;

import haxe.ui.locale.LocaleManager;
import haxe.ui.macros.ComponentMacros;
//import haxe.ui.parsers.locale.CSVParser;
//import haxe.ui.parsers.locale.LocaleParser;
import js.Browser;

//import haxe.ui.tooltips.ToolTipManager;
import http.MailHelper.Result;
using StringTools;

/**
 * ...
 * @author bb
 */
class TMApp extends AppBase
{
	// forms
	var currentForm:Component;
	var forms:Map<String, Component>;
	var content:Component;
	var inbound:Component;
	var outbound:Component;
	var mail:Component;
	var ticket:Component;
	var telesales:Component;
	// UI
	
	var versionLabel:Label;
	var tmMetadatas:Map<String, Dynamic>;
	var justifications:Array<TextArea>;
	var communicator:MessageBox;

	var summaries:Array<TextArea>;
	var failedCriticals:Float;
	var failedOverall:Float;
	var countQuestions:Float;
	var whatToSend:CheckBox;

///////////////////////////////////////////////////////////
	var monitoringReasonValue:String;
	var monitoringTypeValue:String;
	var monitoringSummaryValue:String;
	var transactionSummaryValue:String;
///////////////////////////////////////////////////////////
	var formSwitcher: Group;
	var monitoringType:Group;
	var monitoringReason:Group;
	var transactionUI:Transaction;
	var agentlisting:AgentListing;	
	var tracker:tm.Tracker;
	var mailComposer: tm.TMMailer;


	//var info:Component;
	public function new()
	{
		super(TMMailer, tm.Tracker);
		currentForm = null;
		forms = new Map<String, Component>();
		trace("start");
		tracker = cast(this.xapitracker, tm.Tracker);
		trace("end");
		mailComposer = cast(this.mailHelper, TMMailer);
		tracker.signal.add(this.onXapiTracking) ;
		
		//cast(this.onXapiTracking, Tracker).signal.add(this.onXapiTracking) ;
		
		this.whenAppReady = loadContent;
		
		app.ready(onAppReady);
	}
	function onXapiTracking(stage:Int)
	{
		if (stage == -1)
		{
			trace("errror with the XAPI");
			debounce = true;
		}
		else if (stage == 1)
		{
			//var score = Question.GET_SCORE();
			tracker.coachTracking( monitoringData.coach,transactionData.monitoree, transactionData.type, tm.Question.SCORE, tm.Question.FAILED_CRITICAL.length == 0, AppBase.lang, tmMetadatas);

		}
		else if (stage == 2)
		{
			sendEmailToBoth(tracker.monitoreeRecieved);

		}
	}

	override function onMailSucces(r:Result)
	{
		super.onMailSucces(r);
		//debounce = true;
		mainApp.removeComponent(preloader,false);
		var dialogEnd = new MessageBox();

		if (r.status == "success")
		{

			dialogEnd.width = 560;
			dialogEnd.height = 560;
			dialogEnd.draggable = false;
			dialogEnd.type = MessageBoxType.TYPE_INFO;
			dialogEnd.message = "{{DIALOG_MSG_SUCCESS_TRUE}}";
			dialogEnd.title = "{{DIALOG_TITLE_SUCCESS_TRUE}}";
		}
		else
		{
			//var dialogError = new MessageBox();
			dialogEnd.width = 560;
			dialogEnd.height = 560;
			dialogEnd.draggable = false;
			dialogEnd.type = MessageBoxType.TYPE_ERROR;
			dialogEnd.message = "{{DIALOG_MSG_SUCCESS_FALSE}}";
			dialogEnd.title = "{{DIALOG_TITLE_SUCCESS_FALSE}}";
		}
		try
		{
			#if debug
			trace("Main::onMailSucces::s", r, dialogEnd.message );
			#end
			dialogEnd.showDialog(true);
			reset();
		}
		catch (e:Exception)
		{
			trace(e);
		}
	}

	function reset()
	{
		#if debug
		trace("TMApp::reset::reset", reset );
		#end
		
		tracker.start();
		content.hidden = true;
		agentlisting.reset();
		swapContent(agentlisting);
		resetForm();
		resetTransaction();
		resetMonitoring();
	}

	function resetForm()
	{
		tm.Question.RESET();

	}

	//override function onLoginSuccess(agent:Actor)
	//{
		//if (Std.isOfType(agent, Coach))
		//{
			//if (agent.authorised)
			//{
				//monitoringData.coach  = cast(agent, Coach);
//
				//cookie.flush(version, monitoringData.coach );
				//loadContent();
			//}
			//else
			//{
				////loginFeedback.addClass("error");
				//loginApp.feedErrorBack(agent.title);
			//}
		//}
		//else if (Std.isOfType(agent, Monitoree ))
		//{
			//transactionData.monitoree = cast(agent, Monitoree);
//
			//resetAgent();
			//if (transactionData.monitoree.authorised)
			//{
//
				//agentLabel.htmlText = '<strong class="correct">${StringTools.replace(transactionData.monitoree.mbox, "mailto:","")}</strong>\n${transactionData.monitoree.title}';
				///*agentLabel.color = 0x65a63c;*/
				//agentLabel.addClass("correct");
				//agentOK.resource = "images/check-green-icon.png";
				//agentOK.hidden = false;
//
				//if (transactionData.monitoree.manager != null)
				//{
					//cctl_text.text = StringTools.replace(transactionData.monitoree.manager.mbox, "mailto:", "");
					//cctl.hidden = false;
					//cctl_text.hidden = false;
				//}
				//else
				//{
					//cctl.hidden = true;
					//cctl_text.hidden = true;
				//}
//
				//tracker.start();
			//}
			//else
			//{
//
				//agentOK.hidden = false;
				//agentOK.resource = "images/check-red-icon.png";
				//agentLabel.htmlText = '{{ERROR}} \n<strong class="error">${transactionData.monitoree.name}</strong>';
				//agentLabel.addClass("error");
				///*agentLabel.color = 0xFF0000;*/
			//}
			//#if debug
			////trace("TMApp::onLoginSuccess::agentLabel.hidden", agentLabel.hidden );
			////trace("TMApp::onLoginSuccess::agentLabel.text", agentLabel.htmlText);
			//#end
			//agentLabel.updateComponentDisplay();
		//}
	//}
	/*function resetAgent(?fromscratch:Bool=false)
	{
		cctl.hidden = true;
		cctl_text.hidden = true;
		cctl.selected = false;
		agentLabel.removeClass("error");
		agentLabel.removeClass("correct");
		agentOK.hidden = true;
		if (fromscratch)
		{
			agentTF.text = "";
			agentLabel.htmlText = "";
		}
	}*/
	function loadContent()
	{
		if (loginApp != null) app.removeComponent(loginApp);
		this.mainApp = ComponentMacros.buildComponent("assets/ui/main.xml");
       
		communicator = new Communicator();
		//mainApp = ComponentMacros.buildComponent("assets/ui/main.xml");
		app.addComponent(mainApp);

		//
		prepareVersion();
		prepareForms();
		prepareHeader();
		prepareMetadatas();
		
		markdownHelper.show();

		content = mainApp.findComponent("content", null, true);
		agentlisting = new AgentListing(monitoringData.coach);
		agentlisting.signal.add( onAgentListingChanged);
		agregator.signal.add( agentlisting.displayList );
		content.addComponent( agentlisting );
		//content.removeComponentAt(0,false);
		try
		{
			//agregator.getBasicTMThisMonth(monitoringData.coach.directReports);
			//agregator.signal.add(onTmFecteched);
		}
		catch (e)
		{
			trace(e);
		}
		//setCurrentForm("inbound");
	}

	function onAgentListingChanged(s:String)
	{
		switch (s)
		{
			case "myTm" : agregator.getBasicTMThisMonth(monitoringData.coach.sAMAccountName);
			case "myDr" : agregator.getDirectReportsTMThisMonth(monitoringData.coach.directReports);
			case _ : onAgentSelectInList(s);

		}
	}

	/*function onTmFecteched(list:Array<Dynamic>)
	{
		#if debug
		trace("TMApp::onTmFecteched");
		#end
		//var agents = monitoringData.coach.getDirectReportsAMAccountNames();
		//var al:AgentListing = new AgentListing(monitoringData.coach, list);
		al.signal.add(onAgentSelectInList);
		content.addComponent(al);
	} */

	override function prepareMetadatas()
	{
		super.prepareMetadatas();
		#if debug
		trace("TMApp::prepareMetadatas");
		#end
		//agentLabel = mainApp.findComponent("agentlabel", Label);
		//agentOK = mainApp.findComponent("agewntOK", Image);
		formSwitcher = mainApp.findComponent("formSwitcher", null, true);
		formSwitcher.onChange = (e:UIEvent)->setCurrentForm(e.target.id);
		//transactionIdTF = mainApp.findComponent("transactionID", TextField);

		//transactionDateComp = mainApp.findComponent("TRANSACTION_WHEN", DropDown);

		//transactionDateComp.onChange = (e)->(prepareTransactionDate());
		//transcationHourComp = mainApp.findComponent("TRANSACTIONWHENHOURS", NumberStepper, true, "id");
		//#if debug
		//var testTHour  = transcationHourComp == null;
		//trace("TMApp::prepareMetadatas::transcationHourComp", testTHour );
		//#end
		//transcationHourComp.onChange = (e)->(prepareTransactionDate());
		//transcationMinutesComp = mainApp.findComponent("TRANSACTION_WHEN_MINUTES", NumberStepper);

		//transcationMinutesComp.onChange = (e)->(prepareTransactionDate());

		//agentBtn = mainApp.findComponent("agentBtn");
		//agentTF = mainApp.findComponent("agentNt");
		//agentTF.registerEvent(FocusEvent.FOCUS_OUT, onAgentFilledIn);
		//agentBtn.onClick = onAgentClicked;

		//coachEmail = mainApp.findComponent("coachemail", Label);
		//coachEmail.htmlText = '<strong>${StringTools.replace(monitoringData.coach.mbox, "mailto:","")}</strong>\n${monitoringData.coach.title}';
		//coachEmail.onClick = onCoachClicked;
		//transactionSummary = mainApp.findComponent("transactionsummary", TextArea);
		//var transactionSummaryLabel = mainApp.findComponent("tsummary", Label);
		//transactionSummaryLabel.onClick = (e)->(markdownHelper.show());
		//var monitoringSummaryLabel = mainApp.findComponent("msummary", Label);
		//monitoringSummaryLabel.onClick = (e)->(markdownHelper.show() );
		//transactionSummary.registerEvent(FocusEvent.FOCUS_OUT, onTransactionOut);
		//transactionSummary.onMouseOut = onTransactionOut;

		//monitoringSummary =  mainApp.findComponent("monitoringsummary", TextArea);
		monitoringType = mainApp.findComponent("type", Group);
		monitoringReason = mainApp.findComponent("reason", Group);
		//monitoringType.onChange = (e)->(monitoringTypeValue = (e.target.id));
		monitoringType.onChange = (e)->(monitoringData.data.set( data.Monitoring.MONITORING_TYPE, e.target.id));
		//monitoringReason.onChange = (e)->(monitoring.data.set(Monitoring.MONITORING_REASON,e.target.id));
		monitoringReason.onChange = onMonitoringReasonChanged;
		/**/
	}

	//function onTransactionOut(e:MouseEvent):Void
	//{
	//trace(transactionSummary.text);
	//trace(Markdown.markdownToHtml(transactionSummary.text));
	//
	//transactionSummary.htmlText = Markdown.markdownToHtml(transactionSummary.text);
	//}
	function onMonitoringReasonChanged(e)
	{
		var id = cast(e.target, Component).id;
		cctl.hidden = cctl_text.hidden = (id == "calibration" || transactionData.monitoree == null || transactionData.monitoree.manager ==null );
		monitoringData.data.set(data.Monitoring.MONITORING_REASON, id);
	}
	override function resetMonitoring()
	{
		super.resetMonitoring();
		cast(monitoringReason.getComponentAt(0), OptionBox).resetGroup();
		cast(monitoringType.getComponentAt(0), OptionBox).resetGroup();
	}

	override function resetTransaction()
	{
		super.resetTransaction();
		cast(formSwitcher.getComponentAt(0), OptionBox).resetGroup();
	}



	override function prepareHeader()
	{
		super.prepareHeader();
		//sendBtn = mainApp.findComponent("send",Button);
//
		//langSwitcher = mainApp.findComponent("langSwitcher", null, true);
		//langSwitcher.onChange = onLangChanged;
		////langSwitcher.disabled = true;
//
		//sendBtn.onClick = onSend;
		whatToSend = mainApp.findComponent("sendAll", CheckBox);
		//cctl = mainApp.findComponent("cctl", CheckBox);
		//cctl_text = mainApp.findComponent("cctl_text", Label);
		//whatToSendLabel = mainApp.findComponent("slider2", Label);
		whatToSend.onChange = (e)->(whatToSend.text = whatToSend.selected? "{{ALL}}" : "{{FAILED_ONLY}}");
	}

	function prepareForms()
	{
		forms = [];
		tm.Question.INFO = new tm.Info(mainApp.findComponent("info"));
		inbound = ComponentMacros.buildComponent("assets/ui/content/inbound.xml");
		mail = ComponentMacros.buildComponent("assets/ui/content/mail.xml");
		telesales = ComponentMacros.buildComponent("assets/ui/content/telesales.xml");
		ticket = ComponentMacros.buildComponent("assets/ui/content/ticket.xml");
		telesales = ComponentMacros.buildComponent("assets/ui/content/telesales.xml");
		forms.set("inbound", inbound);
		forms.set("mail", mail);
		forms.set("ticket", ticket);
		forms.set("telesales", telesales);
	}

	function prepareVersion()
	{
		versionLabel = mainApp.findComponent("version", Label);
		versionLabel.text = "v " + version;
	}

	
	
	/**
	function onLoginClicked(e:MouseEvent)
	{
		loginFeedback.removeClass("error");
		try
		{
			logger.prepareCredentials(coachUsername.text, coachPWD.text);
			logger.send();
		}
		catch (e:Exception)
		{
			loginFeedback.addClass("error");
			loginFeedback.text = e.message;
		}
		catch (e:Dynamic)
		{
			loginFeedback.addClass("error");
			loginFeedback.text = e.message;
		}
	}
	 **/
	override function onSend(e)
	{
		super.onSend(e);
		
		var resultCheck = tm.Question.PREPARE_RESULTS();
		this.submitor.messages = this.submitor.messages.concat(resultCheck.messages);
		this.submitor.canSubmit =  this.submitor.canSubmit && resultCheck.canSubmit;
		if (this.submitor.canSubmit)
		{
			debounce = false;
			transactionData.prepareData();

			// PREPARE XAPI METADATA EXTENSIONS
			tmMetadatas = Utils.addPrefixKey(
							  Browser.location.origin +Browser.location.pathname,
							  Utils.mergeMaps(
								  Utils.mergeMaps( transactionData.data, monitoringData.data ),
								  Utils.stringyfyMap(tm.Question.CRITICALITY_MAP)
							  )
						  );

			// PREPARE QUESTION EXTENSIONS
			var questionExtensions:Map<String,String> = Utils.addPrefixKey(Browser.location.origin + Browser.location.pathname, tm.Question.RESULT_MAP);

			if (monitoringData.data.get(data.Monitoring.MONITORING_REASON) == "calibration")
			{
				// CALIBRATION
				tracker.callibrationTracking(
					monitoringData.coach,
					transactionData.type,
					tmMetadatas,
					transactionData.monitoree,
					tm.Question.SCORE,
					tm.Question.TM_PASSED,
					AppBase.lang,
					questionExtensions);

			}
			else
			{
				// TM AGENT TRACK
				tracker.agentTracking(
					transactionData.monitoree,
					monitoringData.coach,
					transactionData.type,
					tmMetadatas,
					tm.Question.SCORE,
					tm.Question.TM_PASSED,
					questionExtensions,
					AppBase.lang);
			}

		}
		else
		{
			this.submitor.messages.unshift(LocaleManager.instance.lookupString("DIALOG_APPLY_YOURSELF",  monitoringData.coach.firstName));
			communicator.message = this.submitor.messages.join("\n\n");
			communicator.showDialog(true);
		}
	}
	
	override function validateMetadatas():Utils.Status
	{
        var s = super.validateMetadatas();	
		if (transactionData.type == "")
		{
			s.canSubmit = false;
			s.messages.push("{{ALERT_TRANSACTION_TYPE}}");
		}
		

		if (!monitoringData.data.exists(data.Monitoring.MONITORING_REASON))
		{
			s.canSubmit = false;
			s.messages.push("{{ALERT_MONITORING_REASON}}");
		}
		else{
			#if debug
			//trace("TMApp::validateMetadatas::monitoring.data.exists(Monitoring.MONITORING_REASON)", monitoring.data.exists(Monitoring.MONITORING_REASON) );
			#end
		}
		if (!monitoringData.data.exists(data.Monitoring.MONITORING_TYPE))
		{
			s.canSubmit = false;
			s.messages.push("{{ALERT_MONITORING_TYPE}}");
		}
		else{
			#if debug
			//trace("TMApp::validateMetadatas::monitoring.data.exists(Monitoring.MONITORING_TYPE)", monitoring.data.exists(Monitoring.MONITORING_TYPE) );
			#end
		}
		return s;
	}
	/*function onFormChanged(e:UIEvent)
	{
		setCurrentForm(e.target.id);
	}*/
	function setCurrentForm(id:String)
	{
		#if debug
		trace('TMApp::setCurrentForm::id ${id}');
		#end
		tm.Question.INFO.reset();

		transactionData.type = id;
		currentForm = forms.get(id);
		swapContent(currentForm);
		tm.Question.GET_ALL(currentForm);
		LocaleManager.instance.language = "en";
		LocaleManager.instance.language = AppBase.lang;
	}
	function swapContent(c:Component, ?hide:Bool=false )
	{
		content.removeComponentAt(0,false);
		content.addComponentAt(c, 0 );
		content.hidden = hide;
	}

	

	function sendEmailToBoth(?previousStatement:StatementRef):Void
	{
		#if debug
		//trace("TMApp::sendEmailToBoth");
		#end
		//dialog.message = "Wait...";
		//dialog.showDialog(true);
		tm.Question.INFO.reset();
		//preloader.width = 250;
		//preloader.height = 140;
		//preloader.verticalAlign ="center";
//
		//mainApp.addComponent(preloader);
//
		mailComposer.cctl = cctl.selected;
		mailComposer.transaction = transactionData;
		mailComposer.monitoring = monitoringData;

		mailComposer.build(whatToSend.selected, previousStatement, version);
		super.sendEmail();
		
	}

}
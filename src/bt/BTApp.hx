package bt;
import haxe.Exception;
import haxe.ds.StringMap;
import haxe.ui.Toolkit;
import haxe.ui.components.Button;
import haxe.ui.components.CheckBox;
import haxe.ui.components.Column;
import haxe.ui.components.DropDown;
import haxe.ui.components.Label;
import haxe.ui.components.TextArea;
import haxe.ui.components.TextField;
import haxe.ui.containers.Group;
import haxe.ui.containers.TabView;
import haxe.ui.containers.TableView;
import haxe.ui.containers.TreeView;
import haxe.ui.containers.TreeViewNode;
import haxe.ui.containers.VBox;
import haxe.ui.containers.dialogs.MessageBox;
import haxe.ui.core.Component;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.data.DataSource;
import haxe.ui.events.ItemEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.locale.LocaleManager;
import haxe.ui.macros.ComponentMacros;
import http.MailHelper.Result;

import roles.Actor;
using StringTools;
using string.StringUtils;
using helpers.Translator;
using regex.ExpReg;

/**
 * ...
 * @author bb
 */
typedef DropDownItem =
{
	var text:String;
	var value:String;
}
typedef TableViewItem =
{
	var text:String;
	var value:String;
}
typedef Validator =
{
	var label:Label;
	var value:Dynamic;
	var ready:Bool;
	var alert:String;
	var order:Int;
}
class BTApp extends AppBase
{
	var _selectedCat:String;
	public static inline var CAT_STRING_SEPERATOR:String = "_";
	var fedbackCat:Map<String,Dynamic> =
		[
			"catAgent"=>[
				"catAgent_ticket" => [
					'catAgent_ticket_stateoftheart',
					'catAgent_ticket_unnecessary',
					'catAgent_ticket_duplicate',
					'catAgent_ticket_incomplete',
					'catAgent_ticket_wrongcat',
					'catAgent_ticket_wronglang',
					'catAgent_ticket_notool'],
				"catAgent_answering" => [
					'catAgent_answering_stateoftheart',
					'catAgent_answering_wronginfo',
					'catAgent_answering_wrongoto',
					'catAgent_answering_wrongpp',
					'catAgent_answering_wrongoption',
					'catAgent_answering_noret'
				],
				"catAgent_misbehaviour" => [
					'catAgent_misbehaviour_tool',
					'catAgent_misbehaviour_attitude'
				]
			],
			"catProcess" => [
				"catProcess_dysfunction",
				"catProcess_wrongdocumentation",
				"catProcess_nodocumentation"

			],
			"catTool" => [
				"catTool_missingfunk",
				"catTool_access"
			]

		];
	var details_tools_dropdown:DropDown;
	var details_product_dropdown:DropDown;
	var reasons_categories_tree:TreeView;
	var details_person_selector_input_textarea:TextArea;
	var details_person_selector_display_tableview:TableView;
	var details_person_selector_display_box:VBox;

	//var reasons_categories_2_label:Label;
	var reasons_categories_label:Label;

	var details_person_selector_display_label:Label;
	var reasons_description_defect_textarea:TextArea;
	var reasons_description_fix_textarea:TextArea;
	var details_customer_id_textfield:TextArea;
	var details_customer_so_textfield:TextArea;
	var details_process_textfield:TextField;

	var validatorDictionary:Map<Component,Validator>;
	public static inline var BR:String = "\n";
	var _alertMessage:String;
	var toValidate:Array<Component>;
	var allInteractiveComps:Array<Component>;
	static inline var ALERT_CSS_CLASS:String = "alert";
	var app_label:Label;
	var version_label:Label;
	var reasons_description_defect_label:Label;
	var reasons_description_fix_label:Label;
	var details_label:Label;
	var details_customer_id_label:Label;
	var details_customer_so_label:Label;
	var details_person_label:Label;
	var details_person_selector_input_label:Label;
	var details_process_label:Label;
	var details_tools_label:Label;
	var details_product_label:Label;
	var strictProcess:Bool;
	var mailsToSend:Int;
	var storingBT:MessageBox;
	var allSelected:Bool;
	//static inline var NEW_LINE:String = "\n";
	public static inline var CAT_AGENT:String = "catAgent";
	public static inline var CAT_PROCESS:String = "catProcess";
	public static inline var details_person_selector_input_textarea_alert:String = "details_person_selector_input_textarea_alert";
	public static inline var details_person_selector_display_tableview_alert:String = "details_person_selector_display_tableview_alert";
	public static inline var details_customer_id_textfield_alert:String = "details_customer_id_textfield_alert";
	public static inline var details_customer_so_textfield_alert:String = "details_customer_so_textfield_alert";
	public static inline var details_process_textfield_alert:String = "details_process_textfield_alert";
	public static inline var details_product_dropdown_alert:String = "details_product_dropdown_alert";
	public static inline var details_tools_dropdown_alert:String = "details_tools_dropdown_alert";
	public static inline var reasons_categories_tree_alert:String = "reasons_categories_tree_alert";
	public static inline var reasons_description_defect_textarea_alert:String = "reasons_description_defect_textarea_alert";
	public static inline var reasons_description_fix_textarea_alert:String = "reasons_description_fix_textarea_alert";

	public function new( )
	{
		Toolkit.theme = "dark";
		super(BTMailer, BTTracker, "better_together");
        allSelected = false;
		this.whenAppReady = loadContent;
        init();
		//app.ready(onAppReady);

	}
	function reset(?initial:Bool=true)
	{
		try
		{
			#if debug
			trace("bt.BTApp::reset1");
			#end
			if (!initial) reasons_categories_tree.clearNodes();
			buildTree(fedbackCat, null, initial );
			#if debug
			trace("bt.BTApp::reset2");
			#end
			details_person_selector_display_box.hidden = true;

			_selectedCat = "";
			toValidate = [];
			mailsToSend = 0;
			getParamsToFields();
			#if debug
			trace("bt.BTApp::reset3");
			#end
			resetInteractiveComponents();
			addProducts();
			addTools();
			checkWhatToValidate();
			checkMandatoriesValues(false);
			#if debug
			trace("bt.BTApp::reset4");
			#end
		}
		catch (e)
		{
			trace(e);
		}

	}
	function resetInteractiveComponents()
	{
		for (i in allInteractiveComps)
		{
			switch (Type.getClass(i))
			{
				case  DropDown:
					{
						cast(i, DropDown).selectedItem = null;
						cast(i, DropDown).selectedIndex = -1;
						cast(i, DropDown).text = "details_tools_dropdown".T();

					}
				case  TextField: cast(i, TextField).text = "";
				case  TableView: cast(i, TableView).dataSource.clear() ;
				case  TextArea: cast(i, TextArea).text = "";
				case  TreeView:
					{
						cast(i, TreeView).selectedNode = null;
					}
				case _: trace("WTF");
			}

		}
	}
	function getParamsToFields()
	{
		#if debug
		trace("bt.BTApp::getParamsToFields");
		#end
		if (Main.PARAMS.get("person") != null)
		{
			details_person_selector_input_textarea.text=Main.PARAMS.get("person");
		}
		if (Main.PARAMS.get("qook") != null)
		{
			details_process_textfield.text = Main.PARAMS.get("qook");
		}
		#if debug
		trace("bt.BTApp::getParamsToFields::Main.PARAMS.get(qook)", Main.PARAMS.get("qook") );
		#end
	}

	function loadContent()
	{

		try
		{

			if (loginApp != null) app.removeComponent(loginApp);
			this.mainApp = ComponentMacros.buildComponent("assets/ui/main.xml");
			storingBT = new MessageBox();
			storingBT.type = MessageBoxType.TYPE_INFO;
			storingBT.title = "SENDING";
			storingBT.message = "...";
			//storingBT.backgroundImage = preloader.resource;
			storingBT.destroyOnClose = false;
			storingBT.draggable = false;
			storingBT.disabled = true;

			var aggregator = new BTAgregator();

			logger.manySignal.add(onManyFound);
			xapitracker.dispatcher.add(onTracking);

			allInteractiveComps = [];
			manageComponents();
			validatorDictionary = [];

			app.addComponent( mainApp );
			#if debug
			trace("bt.BTApp::loadContent");
			#end

			#if debug
			trace("WTF");

			#end
			reset();
		}
		catch (e)
		{
			trace(e);
		}
	}

	function manageComponents()
	{
		try
		{
			fetchLabels();
			fetchTextarea();
			fetchTextFeilds();
			fetchDropdowns();
			fetchButtons();
			fetchInteractions();
			fetchBoxes();
		}
		catch (e)
		{
			trace(e);
		}
	}

	function fetchBoxes()
	{
		details_person_selector_display_box = mainApp.findComponent("details_person_selector_display_box", VBox);
	}

	function buildTree(root:Map<String,Dynamic>, node:TreeViewNode, ?fromParams:Bool=true)
	{
		#if debug
		trace("bt.BTApp::buildTree", fromParams);
		#end

		
		var reasonsparams = "";
		if (fromParams && Main.PARAMS.get("cat") != null && Main.PARAMS.get("cat").trim() !="" )
		{
			reasonsparams = Main.PARAMS.get("cat");

		}

		var subNode:TreeViewNode;
		for (k => v in root)
		{
			var n:TreeViewNode = if (node == null)
			{
				// first level

				subNode = reasons_categories_tree.addNode({text: k.T(),value:k});
			}
			else
			{
				subNode = node.addNode({text:k.T(), value:k});
			}
			subNode.expanded = fromParams && reasonsparams.indexOf( subNode.data.value) >-1;

			if (Type.getClass(v) == StringMap)
			{
				//recurse
				buildTree(v, n, fromParams);
			}
			else
			{
				// final level
				var val:Array<Dynamic> = cast(v, Array<Dynamic>);

				for (i in val)
				{
					subNode = n.addNode({text: cast(i, String).T(), value:i});
					//#if debug
					//trace("bt.BTApp::buildTree::subNode", subNode.data.value );
					//#end
					if (fromParams && reasonsparams.indexOf( subNode.data.value) >-1)
					{
						reasons_categories_tree.selectedNode = subNode;
						onTreeChanged( new UIEvent(UIEvent.CHANGE) );
					}
				}
			}
		}

	}
	function fetchInteractions()
	{
		var langSwitcher_group:Group = mainApp.findComponent("langSwitcher_group", Group);
		details_person_selector_display_tableview = mainApp.findComponent("details_person_selector_display_tableview", TableView);
		var colx:Column = cast(details_person_selector_display_tableview.findComponent("selected", Column), Column);
		//colx.onClick = (e:MouseEvent)->(trace(e.target.id));
		colx.onClick = toggleSelectAll;
		reasons_categories_tree = mainApp.findComponent("reasons_categories_tree", TreeView);
		reasons_categories_tree.onChange = onTreeChanged;

		allInteractiveComps.push(details_person_selector_display_tableview);
		allInteractiveComps.push(reasons_categories_tree);

	}
	function toggleSelectAll(e:MouseEvent)
	{
		 allSelected = !allSelected;
		var dataSource:DataSource<Dynamic> = details_person_selector_display_tableview.dataSource.clone();
		var data:Array<Dynamic> = cast (dataSource.data, Array<Dynamic>);
		//trace(data);
		details_person_selector_display_tableview.dataSource.clear();
		//trace(data);
		 for (i in data)
		 {
			 i.selected = allSelected;
			 details_person_selector_display_tableview.dataSource.add(i);
		 }
	}

	function fetchButtons()
	{
		var details_person_selector_button:Button = mainApp.findComponent("details_person_selector_button", Button);
		details_person_selector_button.onClick = onSearchAgent;
		var send_button:Button = mainApp.findComponent("send_button", Button);
		send_button.onClick = onSendClicked;
	}

	function fetchDropdowns()
	{
		details_tools_dropdown = mainApp.findComponent("details_tools_dropdown", DropDown);
		details_product_dropdown = mainApp.findComponent("details_product_dropdown", DropDown);

		allInteractiveComps.push(details_tools_dropdown);
		allInteractiveComps.push(details_product_dropdown);

	}

	function fetchTextFeilds()
	{
		
		details_process_textfield = mainApp.findComponent("details_process_textfield", TextField);

		allInteractiveComps.push(details_customer_id_textfield);
		allInteractiveComps.push(details_customer_so_textfield);
		allInteractiveComps.push(details_process_textfield);
	}

	function fetchTextarea()
	{
		var T = TextArea;
		details_customer_id_textfield = mainApp.findComponent("details_customer_id_textfield", T);
		details_customer_so_textfield = mainApp.findComponent("details_customer_so_textfield", T);
		reasons_description_defect_textarea = mainApp.findComponent("reasons_description_defect_textarea", T);
		reasons_description_fix_textarea = mainApp.findComponent("reasons_description_fix_textarea", T);
		details_person_selector_input_textarea = mainApp.findComponent("details_person_selector_input_textarea", T);

		allInteractiveComps.push(reasons_description_defect_textarea);
		allInteractiveComps.push(reasons_description_fix_textarea);
		allInteractiveComps.push(details_person_selector_input_textarea);
	}

	function fetchLabels()
	{
		app_label = mainApp.findComponent("app_label", Label);
		version_label = mainApp.findComponent("version_label", Label);
		version_label.text = "v"+version;
		//var cctl_label:Label = mainApp.findComponent("cctl_label", Label);
		reasons_categories_label = mainApp.findComponent("reasons_categories_label", Label);
		reasons_description_defect_label = mainApp.findComponent("reasons_description_defect_label", Label);
		reasons_description_fix_label = mainApp.findComponent("reasons_description_fix_label", Label);
		details_label = mainApp.findComponent("details_label", Label);
		details_customer_id_label = mainApp.findComponent("details_customer_id_label", Label);
		details_customer_so_label = mainApp.findComponent("details_customer_so_label", Label);
		details_person_label = mainApp.findComponent("details_person_label", Label);
		details_person_selector_input_label = mainApp.findComponent("details_person_selector_input_label", Label);
		details_person_selector_display_label = mainApp.findComponent("details_person_selector_display_label", Label);
		details_process_label = mainApp.findComponent("details_process_label", Label);
		details_tools_label = mainApp.findComponent("details_tools_label", Label);
		details_product_label = mainApp.findComponent("details_product_label", Label);
	}

	function addProducts():Void
	{
		details_product_dropdown.dataSource.clear();
		details_product_dropdown.dataSource.add({text:"Salt Mobile B2C", value:"salt_mob_b2c"});
		details_product_dropdown.dataSource.add({text:"Salt Fiber B2C", value:"salt_fib_b2c"});
		details_product_dropdown.dataSource.add({text:"Salt Mobile B2B", value:"salt_mob_b2b"});
		details_product_dropdown.dataSource.add({text:"Salt Fiber B2B", value:"salt_fib_b2b"});
		details_product_dropdown.dataSource.add({text:"LIDL Mobile B2C", value:"lidl_mob_b2b"});
		details_product_dropdown.dataSource.add({text:"DASABO Mobile B2C", value:"dasabo_mob_b2b"});
		details_product_dropdown.dataSource.add({text:"GoMo Mobile B2C", value:"gomo_mob_b2b"});
	}
	function addTools():Void
	{
		details_tools_dropdown.dataSource.clear();
		details_tools_dropdown.dataSource.add({text:"Marilyn", value:"https://customercare.salt.ch"});
		details_tools_dropdown.dataSource.add({text:"Super Office", value:"https://cs.salt.ch"});
		details_tools_dropdown.dataSource.add({text:"Nixxis", value:"https://nixxis.com"});
		details_tools_dropdown.dataSource.add({text:"VTI", value:"https://vti.salt.ch"});
		details_tools_dropdown.dataSource.add({text:"Billshock", value:"https://qook.salt.ch/billshock"});
		details_tools_dropdown.dataSource.add({text:"Mobile trouble", value:"https://qook.salt.ch/mobile_trouble"});
		details_tools_dropdown.dataSource.add({text:"Fiber touble", value:"https://qook.salt.ch/trouble"});
		details_tools_dropdown.dataSource.add({text:"Fiber Churn Management", value:"https://qook.salt.ch/fiber_cmt"});
		details_tools_dropdown.dataSource.add({text:"CC dashboard", value:"https://qook.salt.ch/fiber_cmt"});
	}

	function onManyFound(many:Array<Actor>, rejected:Array<String>, notFound:Int):Void
	{
		if (rejected.length > 0 || notFound > 0)
		{
			#if debug
			trace("bt.BTApp::onManyFound::rejected", rejected );
			trace("bt.BTApp::onManyFound::notFound", notFound );
			#end
			var mb = new MessageBox();
			mb.type = MessageBoxType.TYPE_WARNING;
			mb.title = "search_many_agent_error_title".T();
			mb.message = "search_many_agent_error_content".T(notFound, rejected.join("\n"));
			mb.showDialog(true);
		}
		details_person_selector_display_tableview.dataSource.clear();
		details_person_selector_display_label.text = "details_person_selector_display_label".T();
		details_person_selector_display_tableview.hidden = false;
		for ( i in many)
		{
			details_person_selector_display_tableview.dataSource.add({ selected:false,mail: i.mbox.substr(7), tl: i.manager.mbox.substr(7), actor:i}) ;
		}

	}

	function onTreeChanged(e:UIEvent):Void
	{
        #if debug
		trace("bt.BTApp::onTreeChanged");
		#end
		if (reasons_categories_tree.selectedNode == null) return;
		//var tree:TreeView = cast(e.target, TreeView);
		//var tree:TreeView = cast(e.target, TreeView);
		var selectedNode:TreeViewNode = reasons_categories_tree.selectedNode;

		if (selectedNode.numComponents == 1 )
		{
			_selectedCat = cast(selectedNode.data.value, String);
		}
		else{
			_selectedCat = "";
			reasons_categories_label.text = LocaleManager.instance.lookupString("{{reasons_categories_label}}");
		}
		//trace(sentence);
		//trace(LocaleManager.instance.lookupString(display));
		Lambda.iter(allInteractiveComps, removeMandatoryClass);
		if (_selectedCat != "")
		{
			checkWhatToValidate();
			strictProcess = ["catProcess_dysfunction","catProcess_wrongdocumentation"].indexOf( _selectedCat)> -1;
			Lambda.iter(toValidate, addMandatoryClass);
		}
        #if debug
		trace("bt.BTApp::onTreeChanged::_selectedCat", _selectedCat);
		#end
	}

	function addMandatoryClass(item:Component)
	{
		if (!item.hasClass(ALERT_CSS_CLASS) && (strictProcess && item == details_process_textfield || item != details_process_textfield))
			item.addClass(ALERT_CSS_CLASS);
	}

	function removeMandatoryClass(item:Component)
	{
		try
		{
			item.removeClass(ALERT_CSS_CLASS);
		}
		catch (e:Exception)
		{
			trace( e );
		}
	}
	function onSearchAgent(e:MouseEvent)
	{

		if (details_person_selector_input_textarea.text != null && details_person_selector_input_textarea.text.trim() != "")
		{
			details_person_selector_display_box.hidden = false;
			details_person_selector_display_tableview.hidden = true;
			details_person_selector_display_label.text = "details_person_selector_display_tableview_searching".T();

			this.logger.searchMany(details_person_selector_input_textarea.text.split("\n"), true);
		}
	}

	function onSendClicked(e:MouseEvent):Void
	{
		//var reciepients = details_person_selector_display_tableview.dataSource.data;

		//trace(checkMandatoriesValues());
		//reset(false);
		if (checkMandatoriesValues())
		{
			//sendEmail();
			doTracking();
		}
	}

	function doTracking()
	{
		var tracker:BTTracker = cast(xapitracker, BTTracker);
		//validatorDictionary.get();
		var mainCat = _selectedCat.split(CAT_STRING_SEPERATOR).shift();
		//var validatorArray:Array<Validator> = Lambda.array(validatorDictionary);
		storingBT.showDialog(true);
		storingBT.message = "tracking...";
		if (mainCat == CAT_AGENT)
		{
			// agent recieve tracking
			tracker.setRecieveVerb();
			tracker.setContext(monitoringData.coach);
			tracker.setActivityObject(_selectedCat, validatorDictionary);
			//tracker.setActivityObjectFromArray(_selectedCat, validatorArray);
			tracker.sendMultipleStatements(  
				cast(validatorDictionary.get(details_person_selector_display_tableview).value, Array<Dynamic>)
				.map((e)->(return e.actor))
			);
		}
		else
		{
			tracker.setReviewdVerb();
			tracker.setContext(monitoringData.coach);
			if (mainCat == CAT_PROCESS)
			{
				var process = validatorDictionary.get(details_process_textfield).value;
				if (ExpReg.URL_START.STRING_TO_REG().match(process))
				{
					//tracker.setActivityObjectFromArray(process, validatorArray);
					tracker.setActivityObject(process, validatorDictionary);

				}
				else
				{
					tracker.setActivityObject("https://qook.salt.ch/undocumented" + process, validatorDictionary);
					//tracker.setActivityObjectFromArray("https://qook.salt.ch/undocumented" + process, validatorArray);
				}
			}
			else
			{
				//tool
				tracker.setActivityObject(_selectedCat, validatorDictionary);
				//tracker.setActivityObjectFromArray(_selectedCat, validatorArray);
			}
			// agent reviewed tracking
			tracker.sendSingleStatement(monitoringData.coach);
		}

	}

	override function sendEmail():Void
	{
		storingBT.message = "SENDING_EMAILS".T();

		mailsToSend = BTMailer.BATCH_SEND(
			_selectedCat,
			validatorDictionary,
			details_person_selector_display_tableview,
			[details_person_selector_display_tableview, details_person_selector_input_textarea],
			cast(mailHelper, BTMailer),
			monitoringData.coach,
			xapitracker.statementsRefs
		);
		storingBT.message = "SENDING_EMAILS".T() + " " +mailsToSend;
		//mainApp.addComponent(preloader);// add a image container in the footer or in a dialogbox
	}
	function isReciepientInputReady():Void
	{
		var v = details_person_selector_input_textarea.text == null ? "" :details_person_selector_input_textarea.text.trim();
		validatorDictionary.set(details_person_selector_input_textarea,
		{
			order: 99,
			label: details_person_selector_input_label,
			alert: details_person_selector_input_textarea_alert.T(),
			value : v,
			ready : v != ""
		});

	}
	function isReciepientReady():Void
	{
		var v = details_person_selector_display_tableview.dataSource.data;
		validatorDictionary.set(details_person_selector_display_tableview,
		{
			order: 99,
			label: details_person_selector_display_label,
			alert: details_person_selector_display_tableview_alert.T(),
			value : v,
			ready : v != [] && Lambda.exists(v, (e)->(return e.selected))
		});

	}
	function isCustomerIDready():Void
	{

		var v:String = details_customer_id_textfield.text.trim();
		var matched = v != "";
		var tab = v.split(BR);
		var errorstab = tab.filter((e)->(return !(ExpReg.CONTRACTOR_EREG.STRING_TO_REG("gi").match(e) || ExpReg.MISIDN_LOCAL.STRING_TO_REG("gi").match(e))));
		matched = matched && errorstab.length == 0;
				#if debug
		trace("bt.BTApp::isSOticketIDReady::tab", tab );
		trace("bt.BTApp::isSOticketIDReady::errorstab", errorstab );
		#end
		validatorDictionary.set(details_customer_id_textfield,
		{
			order: 1,
			label: details_customer_id_label,
			alert: details_customer_id_textfield_alert.T() + (errorstab.length > 0?BR +  "details_customer_id_textfield_alert_badFormat".T() + BR + errorstab.join(BR):""),
			value: tab,
			ready: matched
		}
							   );

	}
	function isSOticketIDReady():Void
	{
		var v:String = details_customer_so_textfield.text.trim();
		var matched = v != "";
		var tab = v.split(BR);
		var errorstab = tab.filter((e)->(return !ExpReg.SO_TICKET.STRING_TO_REG("gim").match(e)));
		matched = matched && errorstab.length == 0;
		#if debug
		trace("bt.BTApp::isSOticketIDReady::tab", tab );
		trace("bt.BTApp::isSOticketIDReady::errorstab", errorstab );
		#end
		validatorDictionary.set
		(details_customer_so_textfield,
			{
				order: 2,
				label: details_customer_so_label,
				alert: details_customer_so_textfield_alert.T() + (errorstab.length > 0?BR +  "details_customer_so_textfield_alert_badFormat".T() + BR + errorstab.join(BR):""),
				value: tab,
				ready: matched
			}
		);
	}
	function isProcessIDready(strict:Bool):Void
	{
		var v = details_process_textfield.text.trim();
		validatorDictionary.set(details_process_textfield,
		{
			order: 4,
			label: details_process_label,
			alert: details_process_textfield_alert.T(),
			value: v,
			ready: if (v != "")
				ExpReg.URL_START.STRING_TO_REG().match(v)
				else (strict)? false : true
				}
							   );
	}

	function isProductReady():Void
	{
		var v:DropDownItem = details_product_dropdown.selectedItem;
		validatorDictionary.set(details_product_dropdown,
		{
			order: 3,
			label: details_product_label,
			alert: details_product_dropdown_alert.T(),
			value: v == null ? "": v.value,
			ready: v != null
		}
							   );
		//return _details_product_value != null;
	}
	function isToolReady():Void
	{
		//var _details_tools_value:DropDownItem = details_tools_dropdown.selectedItem;
		var v:DropDownItem = details_tools_dropdown.selectedItem;
		validatorDictionary.set(details_tools_dropdown,
		{
			order: 5,
			label: details_tools_label,
			alert: details_tools_dropdown_alert.T(),
			value: v == null ? "": v.value,
			ready: v != null
		}
							   );
	}
	function isCatSelected():Void
	{
		validatorDictionary.set(reasons_categories_tree,
		{
			order: 0,
			label: reasons_categories_label,
			alert: reasons_categories_tree_alert.T(),
			value: _selectedCat,
			ready: _selectedCat != ""
		}
							   );
		//return _selectedCat != "";
	}
	function isReasonsDefectReady()
	{
		var  v:String = reasons_description_defect_textarea.text == null ? "": reasons_description_defect_textarea.text.trim();
		validatorDictionary.set(reasons_description_defect_textarea,
		{
			order: 6,
			label: reasons_description_defect_label,
			alert: reasons_description_defect_textarea_alert.T(),
			value: v,
			ready: v != ""
		}
							   );
	}
	function isReasonsFixReady()
	{
		var  v:String = reasons_description_fix_textarea.text == null ? "": reasons_description_fix_textarea.text.trim();
		validatorDictionary.set(reasons_description_fix_textarea,
		{
			order: 7,
			label: reasons_description_fix_label,
			alert: reasons_description_fix_textarea_alert.T(),
			value: v,
			ready: v != ""
		}
							   );
	}

	function checkWhatToValidate():Void
	{
		toValidate = switch (_selectedCat)
		{
			case "" :[reasons_categories_tree];
			/*case "catAgent_ticket_unnecessary" :
				[
					details_process_textfield,
					reasons_description_defect_textarea,
					reasons_description_fix_textarea,
					details_customer_id_textfield,
					details_customer_so_textfield,
					details_person_selector_display_tableview.hidden?details_person_selector_input_textarea:details_person_selector_display_tableview
				];*/
			case "catAgent_misbehaviour_tool" :
				[
					details_tools_dropdown,
					details_process_textfield,
					reasons_description_defect_textarea,
					reasons_description_fix_textarea,
					/*details_customer_id_textfield,*/
					details_customer_so_textfield,
					details_person_selector_input_textarea,
					details_person_selector_display_tableview

				];

			case "catProcess_dysfunction" | "catProcess_wrongdocumentation" :
				[
					reasons_description_defect_textarea,
					reasons_description_fix_textarea,
					/*details_customer_id_textfield,
					details_customer_so_textfield,*/
					details_process_textfield
				];
			case "catProcess_nodocumentation" :
				[
					details_process_textfield,
					reasons_description_defect_textarea,
					reasons_description_fix_textarea/*,
					details_customer_id_textfield,
					details_customer_so_textfield*/
				];
			case "catTool_missingfunk" | "catTool_access" :
				[
					details_process_textfield,
					reasons_description_defect_textarea,
					reasons_description_fix_textarea,
					/*details_customer_id_textfield,
					details_customer_so_textfield,*/
					details_tools_dropdown
				];
			case 
					'catAgent_answering_stateoftheart'|
					'catAgent_answering_wronginfo'|
					'catAgent_answering_wrongoto'|
					'catAgent_answering_wrongpp'|
					'catAgent_answering_wrongoption'|
					'catAgent_answering_noret'
				: [
					details_process_textfield,
					reasons_description_defect_textarea,
					reasons_description_fix_textarea,
					details_customer_id_textfield,
					/*details_customer_so_textfield,*/
					details_person_selector_input_textarea,
					details_person_selector_display_tableview
				];
			case _: [
					details_process_textfield,
					reasons_description_defect_textarea,
					reasons_description_fix_textarea,
					/*details_customer_id_textfield,*/
					details_customer_so_textfield,
					details_person_selector_input_textarea,
					details_person_selector_display_tableview
				];
		}


	}
	function checkMandatoriesValues(?alert:Bool = true)
	{
		//toValidate = [reasons_categories_tree];
		var subValidatorDictionary:Map<Component,Dynamic> = []; //reset
        var alertHeight = 130;
		//launch the checks
		isCatSelected();

		isCustomerIDready();
		isSOticketIDReady();
		isReasonsDefectReady();
		isReasonsFixReady();
		isProductReady();
		isToolReady();

		isProcessIDready( strictProcess );
		isReciepientInputReady();
		isReciepientReady();

		//isReasonsDefectReady();
		//isReasonsFixReady();

		checkWhatToValidate();
		//subValidatorDictionary = Lambda.map(toValidate, (e)->(validatorDictionary.get(e)));
		for (i in toValidate)
		{
			subValidatorDictionary.set(i, validatorDictionary.get(i));
		}

		if (Lambda.exists(subValidatorDictionary, (e)->(return e.ready == false)))
		{
			//cannot go
			_alertMessage = "";

			for (k => v in subValidatorDictionary)
			{
				if (v.ready)
					removeMandatoryClass(k);
				else
				{
					addMandatoryClass(k);
					appendAlerte(v);
					alertHeight += 20;
				}
			}
			if (alert)
			{
				var msgBox = new MessageBox();
				msgBox.type = MessageBoxType.TYPE_ERROR;
				msgBox.title = "{{wtf}}".T();
				msgBox.message = _alertMessage;
				msgBox.width = 500;
				msgBox.height = alertHeight + (_alertMessage.occurencesOf(BR)*20);
				msgBox.showDialog(true);
			}
			
			//msgBox.backgroundImage = preloader.resource;
			return false;
		}
		else
		{
			// can go
			return true;
		}
	}
	function appendAlerte(item:Validator)
	{
		if (!item.ready)
		{
			_alertMessage = _alertMessage + item.alert + BR + BR;
		}
	}
	override function onMailSucces(r:Result)
	{
		#if debug
		trace("bt.BTApp::onMailSucces");
		#end
		debounce = true;
		mailsToSend--;
		if (mailsToSend == 0)
		{
			#if debug
			trace("bt.BTApp::onMailSucces mailsToSend",mailsToSend);
			#end
			storingBT.message = "All done !";
			storingBT.disabled = false;
			reset(false);

		}
		else
		{
			storingBT.message = Std.string(mailsToSend);
		}
	}
	override function onTracking(success:Bool)
	{

		super.onTracking(success);
		#if debug
		trace("bt.BTApp::onTracking");
		#end
		sendEmail();
	}

}
package bt;
import format.csv.Data.Record;
import format.csv.Reader;
import haxe.Exception;
import haxe.crypto.Base64;
import haxe.ds.StringMap;
import haxe.io.Bytes;
import haxe.ui.Toolkit;
import haxe.ui.ToolkitAssets;
import haxe.ui.components.Button;
import haxe.ui.components.CheckBox;
import haxe.ui.components.Column;
import haxe.ui.components.DropDown;
import haxe.ui.components.Image;
import haxe.ui.components.Label;
import haxe.ui.components.OptionBox;
import haxe.ui.components.TextArea;
import haxe.ui.components.TextField;
import haxe.ui.containers.Group;
import haxe.ui.containers.TabView;
import haxe.ui.containers.TableView;
import haxe.ui.containers.TreeView;
import haxe.ui.containers.TreeViewNode;
import haxe.ui.containers.VBox;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.Dialog.DialogEvent;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.containers.dialogs.MessageBox;
import haxe.ui.core.Component;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.data.DataSource;
import haxe.ui.events.ItemEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.locale.LocaleManager;
import haxe.ui.macros.ComponentMacros;
import http.MailHelper;
import http.MailHelper.Result;
import js.Browser;
import ldap.Attributes;
import ldap.Results;
import mail.Params.ImageData;
//import openfl.display.Bitmap;
//import openfl.display.BitmapData;
import xapi.activities.Definition;

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
/*typedef TableViewItem =
{
	var text:String;
	var value:String;
}*/
typedef Validator =
{
	var label:Label;
	var value:Dynamic;
	var ready:Bool;
	var alert:String;
	var order:Int;
}
typedef TableViewItem =
{
	var selected:Bool;
	var mail:String;
	var tl:String;
	var actor:Actor;
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
					'catAgent_ticket_notool'
				],
				"catAgent_answering" => [
					'catAgent_answering_stateoftheart',
					'catAgent_answering_wronginfo',
					'catAgent_answering_wronginfocontract',
					'catAgent_answering_wrongoto',
					'catAgent_answering_wrongpp',
					'catAgent_answering_wrongoption',
					'catAgent_answering_wrongcaraactivation',
					'catAgent_answering_noret',
					'catAgent_answering_storeredirect',
					'catAgent_answering_insuficientlangskills'
				],
				"catAgent_misbehaviour" => [
					'catAgent_misbehaviour_forcedcontract',
					'catAgent_misbehaviour_noinfo',
					'catAgent_misbehaviour_tool',
					'catAgent_misbehaviour_attitude',
					'catAgent_misbehaviour_winback',
					'catAgent_misbehaviour_equipementticket'
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
	public static inline var BR_CSV:String = "|";
	var _alertMessage:String;
	var toValidate:Array<Component>;
	var allInteractiveComps:Array<Component>;
	static inline var ALERT_CSS_CLASS:String = "alert";

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
	var justLoaded:Bool;
	var debugMail:http.MailHelper;
	var external_dealers:Array<Record>;
	var globalNoTL:Array<String>;
	var printSreen:ImageData;
	var reasons_printscreen_title_label:Label;
	var reasons_printscreen_button:Button;
	var printScreenWeigthtMegas:Float;
	//var printscreenExt;
	//var printscreenFileName;
	//var printscreenByteData;
	public var reasons_printscreen_image:Image;
	//static inline var NEW_LINE:String = "\n";
	public static inline var CAT_AGENT:String = "catAgent";
	public static inline var CAT_PROCESS:String = "catProcess";
	public static inline var CAT_TOOL:String = "catTool";
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
		//initImage();
		init();
		justLoaded = true;
		globalNoTL = [];

	}
	function reset(?initial:Bool=true)
	{
		try
		{

			if (!initial)
			{
				checkVersion();// check if new app version before init
			}
			initCatTree(initial);
			initImage();
			details_person_selector_display_box.hidden = true;
			_selectedCat = "";
			toValidate = [];
			mailsToSend = 0;
			external_dealers = Reader.parseCsv(Toolkit.assets.getText("data/dealers.csv"),";");

			resetInteractiveComponents();
			addProducts();
			addTools();
			checkWhatToValidate();
			checkMandatoriesValues(false);
			xapitracker.start();
			getParamsToFields();
		}
		catch (e)
		{
			trace(e);
		}

	}

	function initImage()
	{
		reasons_printscreen_title_label.text = "";
		printSreen =
		{
			name : "",
			bytes : null
		}
		printScreenWeigthtMegas = 0;
		//reasons_printscreen_button.text = "{{reasons_printscreen_button}}";
		reasons_printscreen_image.resource = null;
		reasons_printscreen_button.text = "{{reasons_printscreen_button}}";
		reasons_printscreen_button.icon = "images/picture_small.png";
	}
	/**
	 * set the categorie tree
	 * @param	initial
	 */
	function initCatTree(?initial:Bool = true)
	{
		reasons_categories_tree.clearNodes();
		buildTree(fedbackCat, null, initial );
	}
	/**
	 *
	 * @param	root
	 * @param	Dynamic>
	 * @param	node
	 * @param	fromParams
	 */
	function buildTree
	(
		root:Map<String,Dynamic>,
		node:TreeViewNode,
		?fromParams:Bool = true
	)
	{

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

				subNode = reasons_categories_tree.addNode( {text: k.T(), value:k} );
			}
			else
			{
				subNode = node.addNode( {text:k.T(), value:k} );
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
					if (fromParams && reasonsparams.indexOf( subNode.data.value) >-1)
					{
						reasons_categories_tree.selectedNode = subNode;
						onTreeChanged( new UIEvent(UIEvent.CHANGE) );
					}
				}
			}
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
		trace("bt.BTApp::getParamsToFields",Main.PARAMS.has("person"),Main.PARAMS.get("person"));
		#end
		if (Main.PARAMS.has("person"))
		{
			details_person_selector_input_textarea.text=Main.PARAMS.get("person");
		}
		if (Main.PARAMS.has("qook"))
		{
			details_process_textfield.text = Main.PARAMS.get("qook");
		}

	}
	/*********************************************************
	/*********************************************************
	 * * OVERRIDES
	/*********************************************************
	/*********************************************************/
	override function loadContent()
	{
		//tests();

		try
		{
			debugMail = new MailHelper(comonLibs + "mail/index.php");
			debugMail.setTo([BTMailer.BT_MAIL]);
			debugMail.setBcc(["bruno.baudry@salt.ch"]);
			debugMail.setFrom(monitoringData.coach.getSimpleEmail());
			if (monitoringData.coach.manager == null || monitoringData.coach.manager.mbox == "")
			{

				var msg = new MessageBox();
				msg.title = "Error !!!";
				msg.message = 'Hello ${monitoringData.coach.firstName}, it seems that you manager was not found in the Active Directory. In order to function properly, this app need it... Please escalate to your manager to fix this.';
				msg.showDialog(true);
				loginApp.feedErrorBack( msg.title );
				debugMail.setSubject("[Better together Error] TL not found on logon for " + monitoringData.coach.name );
				debugMail.setBody("TL not found for <a href='"+ monitoringData.coach.getSimpleEmail()+"'>" + monitoringData.coach.name + "</a> (" +monitoringData.coach.description + ") " + Std.string(monitoringData.coach));
				debugMail.send(true);
				msg.showDialog(true);
			}
			else
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

				//var aggregator = new BTAgregator();

				logger.manySignal.add(onManyFound);
				xapitracker.dispatcher.add(onTracking);

				allInteractiveComps = [];
				fetchAllComponents();
				validatorDictionary = [];
				this.prepareHeader();
				app.addComponent( mainApp );

				//app.addComponent( mainApp );

				//app_label.text = app_label.text  + " " + this.monitoringData.coach.sAMAccountName;
				version_label.text = version_label.text + versionHelper.cachedVersion;
				version_label.validateComponent();
				reset();
				var l = if (Main.PARAMS.has("lang"))
				{
					//changeLang(Main.PARAMS.get("lang"));
					Main.PARAMS.get("lang");
				}
				else if (monitoringData.coach.mainLanguage.substr(0, 2)!="")
				{
					monitoringData.coach.mainLanguage.substr(0, 2);
				}
				else
				{
					"en";
				}
				cast(mainApp.findComponent(l, OptionBox),OptionBox).selected = true;
				#if debug
				trace("bt.BTApp::loadContent");

				#end
				try
				{
					var thumbnail:Image = mainApp.findComponent("thumbnail", Image);
					var img = Browser.document.createImageElement();
					img.src = 'data:image/jpeg;base64,${monitoringData.coach.thumbnailphoto}';
					thumbnail.resource = img;
					img.onload = function()
					{
						thumbnail.resource = img;
					};
				}

				catch (e)
				{
					trace(e);

				}
				super.loadContent();

			}

		}
		catch (e)
		{
			trace(e);
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
			xapitracker.statementsRefs,
			printSreen
		);
		storingBT.message = "SENDING_EMAILS".T() + " " + mailsToSend;
		//mainApp.addComponent(preloader);// add a image container in the footer or in a dialogbox
	}
	function tests()
	{

	}

	function fetchAllComponents()
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
		catch (e:Exception)
		{
			trace(e.stack);
		}
	}

	function fetchBoxes()
	{
		details_person_selector_display_box = mainApp.findComponent("details_person_selector_display_box", VBox);
		reasons_printscreen_image  = mainApp.findComponent("reasons_printscreen_image", Image);
	}

	function fetchInteractions()
	{
		//var langSwitcher_group:Group = mainApp.findComponent("langSwitcher_group", Group);
		details_person_selector_display_tableview = mainApp.findComponent("details_person_selector_display_tableview", TableView);
		var colx:Column = cast(details_person_selector_display_tableview.findComponent("selected", Column), Column);
		//colx.onClick = (e:MouseEvent)->(trace(e.target.id));
		colx.onClick = toggleSelectAll;
		reasons_categories_tree = mainApp.findComponent("reasons_categories_tree", TreeView);
		reasons_categories_tree.onChange = onTreeChanged;

		allInteractiveComps.push(details_person_selector_display_tableview);
		allInteractiveComps.push(reasons_categories_tree);

	}

	function fetchButtons()
	{
		var details_person_selector_button:Button = mainApp.findComponent("details_person_selector_button", Button);
		details_person_selector_button.onClick = onSearchAgent;
		reasons_printscreen_button = mainApp.findComponent("reasons_printscreen_button", Button);
		reasons_printscreen_button.onClick = openImage;
	}

	function openImage(_)
	{
		#if debug
		trace("bt.BTApp::openImage");
		#end
		var hadIssues = true;
		try
		{
			if (this.printSreen.name != "")
			{
				initImage();

			}
			else
			{
				Dialogs.openBinaryFile("Open Image File", [ {label: "Image File", extension: "png, jpg, jpeg"}], function(selectedFile)
				{

					if (selectedFile != null)
					{

						#if debug
						trace("bt.BTApp::openImage","selected file != null", selectedFile.name, selectedFile.isBinary, selectedFile.bytes.length);
						#end

						if (selectedFile.bytes != null)
						{
							printScreenWeigthtMegas = Math.round(selectedFile.bytes.length * 100 / 1048576) / 100;
							if (selectedFile.bytes.length > 1048576*2)
							{
								var msg = new MessageBox();
								//printScreenWeigthtMegas = Math.round(selectedFile.bytes.length * 100 / 1048576) / 100;
								msg.title = "File error";
								msg.type = MessageBoxType.TYPE_ERROR;
								msg.text = 'File ${printSreen.name} is too big !\n($printScreenWeigthtMegas Megas, Bro !)';
								msg.show();
								initImage();

							}
							else
							{
								//printScreenWeigthtMegas = Math.round(selectedFile.bytes.length * 100 / 1048576) / 100;
								printSreen.name = selectedFile.name;
								printSreen.bytes= Base64.urlEncode(selectedFile.bytes);
								hadIssues = false;
								//updateTabs(selectedFile.bytes,fileName,ext );
								updateTabs( );
								reasons_printscreen_button.text = "{{reasons_printscreen_button_cancel}}";
								reasons_printscreen_button.icon = "images/picture_small_cancel.png";
								//reasons_printscreen_button.invalidateComponent();
								//trace(reasons_printscreen_button.text);
							}

						}
					}
					else
					{
						#if debug
						trace("bt.BTApp::openImage","selected file = null");
						#end
					}

				});
			}
		}
		catch (e)
		{
			trace(e);
		}
		if (hadIssues)
		{
			/*#if debug
			trace("bt.BTApp::openImage : ISSUE ");
			#end
			 */
		}
	}
	//private function updateTabs(byteData:Bytes = null, filename:String = "", extension:String= "")
	private function updateTabs()
	{
		#if debug
		trace("bt.BTApp::updateTabs");
		#end
		var _byteData:Bytes = Base64.urlDecode(printSreen.bytes);

		reasons_printscreen_image.resource = null;
		ToolkitAssets.instance.imageFromBytes(_byteData, function(imageInfo)
		{
			if (imageInfo != null)
			{
				#if debug
				trace("bt.BTApp::updateTabs::reasons_printscreen_image", reasons_printscreen_image.originalWidth, reasons_printscreen_image.height, reasons_printscreen_image.actualComponentWidth);
				trace(imageInfo.width, imageInfo.height);
				#end
				try
				{
					var ratio = if ( imageInfo.width > imageInfo.height)
					{
						380 / imageInfo.width;
					}
					else
					{
						380 / imageInfo.height;
					}
					reasons_printscreen_image.imageScale = ratio;
					reasons_printscreen_image.resource = imageInfo.data;
					reasons_printscreen_title_label.text = printSreen.name +'\n ${imageInfo.width} × ${imageInfo.height} (pixels) \n$printScreenWeigthtMegas Mb';
				}
				catch (e:Exception)
				{
					var errorMB:MessageBox = new MessageBox();
					errorMB.title = "Image error";
					errorMB.text = e.message;
					errorMB.show();
					initImage();
				}
			}
		});
		//dataViewTabs.pageIndex = indexToSelect;

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

		version_label = mainApp.findComponent("version_label", Label);

		reasons_categories_label = mainApp.findComponent("reasons_categories_label", Label);
		reasons_description_defect_label = mainApp.findComponent("reasons_description_defect_label", Label);
		reasons_description_fix_label = mainApp.findComponent("reasons_description_fix_label", Label);
		reasons_description_defect_label.onClick = (e)->(markdownHelper.showDialog(true));
		reasons_description_fix_label.onClick = (e)->(markdownHelper.showDialog(true));
		details_label = mainApp.findComponent("details_label", Label);
		details_customer_id_label = mainApp.findComponent("details_customer_id_label", Label);
		details_customer_so_label = mainApp.findComponent("details_customer_so_label", Label);
		details_person_label = mainApp.findComponent("details_person_label", Label);
		details_person_selector_input_label = mainApp.findComponent("details_person_selector_input_label", Label);
		details_person_selector_display_label = mainApp.findComponent("details_person_selector_display_label", Label);
		details_process_label = mainApp.findComponent("details_process_label", Label);
		details_tools_label = mainApp.findComponent("details_tools_label", Label);
		details_product_label = mainApp.findComponent("details_product_label", Label);
		reasons_printscreen_title_label = mainApp.findComponent("reasons_printscreen_title_label", Label);
	}

	/**************************************************
	/**************************************************
	 * Comp setup
	 *************************************************
	 *************************************************/
	inline function addProducts():Void
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
		/**
		 * @todo refactor to init phases
		 */
		details_tools_dropdown.selectedItem = null;
		#if debug
		//trace("bt.BTApp::addTools::details_tools_dropdown.selectedItem", details_tools_dropdown.selectedItem );
		#end
		details_tools_dropdown.dataSource.clear();
		#if debug
		//trace("bt.BTApp::addTools::details_tools_dropdown.selectedItem", details_tools_dropdown.selectedItem );
		#end
		details_tools_dropdown.dataSource.add({text:"Marilyn", value:"https://customercare.salt.ch"});
		details_tools_dropdown.dataSource.add({text:"Super Office", value:"https://cs.salt.ch"});
		details_tools_dropdown.dataSource.add({text:"Nixxis", value:"https://nixxis.com"});
		details_tools_dropdown.dataSource.add({text:"VTI", value:"https://vti.salt.ch"});
		details_tools_dropdown.dataSource.add({text:"CC dashboard", value:"https://its.salt.ch/ccare"});
		details_tools_dropdown.dataSource.add({text:"Billshock", value:"https://qook.salt.ch/billshock"});
		details_tools_dropdown.dataSource.add({text:"Mobile trouble", value:"https://qook.salt.ch/mobile_trouble"});
		details_tools_dropdown.dataSource.add({text:"Fiber trouble", value:"https://qook.salt.ch/trouble"});
		details_tools_dropdown.dataSource.add({text:"Fiber Churn Management", value:"https://qook.salt.ch/fiber_cmt"});

		details_tools_dropdown.dataSource.add({text:"Qoof", value:"https://qoof.salt.ch"});
		details_tools_dropdown.dataSource.add({text:"Qoom", value:"https://qoom.salt.ch"});
		details_tools_dropdown.dataSource.add({text:"Learningcenter", value:"https://learningcenter.salt.ch"});
		details_tools_dropdown.dataSource.add({text:"Transaction monitoring", value:"https://qook.salt.ch/tm"});
		details_tools_dropdown.dataSource.add({text:"Salt online", value:"https://www.salt.ch/"});
	}

	/***********************************/
	function toggleSelectAll(e:MouseEvent)
	{
		/**
		 * @todo Why cloning ?
		 */
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
	//function onManyFound(many:Array<Actor>, rejected:Array<String>, notFound:Int):Void

	function mapIndirect(s:String)
	{
		var name = s;
		var indi = Lambda.find(external_dealers, (e:Record)->(e[0] == s));
		var mail = indi[1];
		var mailName = indi[1].split("@")[0].split(".");
		var bossFirst = mailName[0];
		var bossLast = mailName[1];
		return new Actor(
		{
			mail:indi[0]+"@" + indi[2] + ".ch",
			samaccountname:indi[2] + "(" + indi[0] +")",
			givenname: indi.join(" "),
			sn:indi[2],

			boss:{
				mail:indi[1],
				samaccountname: bossFirst.substr(0,1) + bossLast.substr(0, 7),
				givenname:bossFirst + " " + bossLast,
				sn:bossFirst
			}
		});
	}
	function mapStoresEmailToActor(s:String)
	{
		#if debug
		trace("bt.BTApp::mapStoresEmailToActor::s.substr(0, s.indexOf('@'))", s.substr(0, s.indexOf("@")) );
		#end
		var name = s.substr(0, s.indexOf("@"));
		return new Actor(
		{
			mail:s,
			samaccountname:name,
			givenname:name,
			sn:name,
			boss:{
				mail:s,
				samaccountname:name,
				givenname:name,
				sn:name
			}
		});
		//return a;
	}
	function showErrorDialog(rejected:Array<String>, leavers:Array<String>, ?tl:Bool=false)
	{
		var mb = new MessageBox();
		mb.width = 600;
		mb.type = MessageBoxType.TYPE_WARNING;
		mb.title = "search_many_agent_error_title".T();
		mb.message = "";
		if (tl)
			mb.message = "search_many_tl_error_content".T(rejected.length, rejected.join("\n"));
		else
		{
			if (rejected.length > 0)
				mb.message += "search_many_agent_error_content".T(rejected.length, rejected.join("\n"));
			if (rejected.length > 0 && leavers.length > 0)   mb.message += "\n\n";

			if (leavers.length > 0)
				mb.message += "search_many_agent_leaver_content".T(leavers.length, leavers.join("\n"));
		}
		mb.showDialog(true);
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

	function doTracking()
	{
		var tracker:BTTracker = cast(xapitracker, BTTracker);
		//validatorDictionary.get();
		var mainCat = _selectedCat.split(CAT_STRING_SEPERATOR).shift();
		#if debug
		//trace("bt.BTApp::doTracking::_selectedCat", _selectedCat );
		#end
		//var validatorArray:Array<Validator> = Lambda.array(validatorDictionary);
		storingBT.showDialog(true);
		storingBT.message = "tracking...";
		tracker.setReviewdVerb();
		//var def:Definition = new Definition();
		//def.extensions = tracker.getExtensions(map);
		tracker.setContext(
			tracker.getExtensions(
				validatorDictionary,
				[
					validatorDictionary.get(details_person_selector_display_tableview),					validatorDictionary.get(details_person_selector_input_textarea)
				]
			),
			monitoringData.coach.manager

		);// instructorSENT BY

		if (mainCat == CAT_AGENT)
		{
			//tracker.setActivityObject(_selectedCat);// for recieving
			tracker.sendMultipleStatements(this.monitoringData.coach, cast(validatorDictionary.get(details_person_selector_display_tableview).value ).map((e)->(return e.actor)));
		}
		else if (mainCat == CAT_PROCESS)
		{
			var process = validatorDictionary.get(details_process_textfield).value;
			if (ExpReg.URL_START.STRING_TO_REG().match(process))
			{
				//tracker.setActivityObjectFromArray(process, validatorArray);
				tracker.setActivityObject(process);

			}
			else
			{
				tracker.setActivityObject("https://qook.salt.ch/undocumented" + process);
				//tracker.setActivityObjectFromArray("https://qook.salt.ch/undocumented" + process, validatorArray);
			}
			// agent reviewed tracking
			tracker.sendSingleStatement(monitoringData.coach);
		}
		else if (mainCat == CAT_TOOL)
		{
			tracker.setActivityObject(validatorDictionary.get(details_tools_dropdown).value);
			tracker.sendSingleStatement(monitoringData.coach);
		}
		else
		{
			throw "Un treated category";
		}

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
		//trace("bt.BTApp::isSOticketIDReady::tab", tab );
		//trace("bt.BTApp::isSOticketIDReady::errorstab", errorstab );
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
		//trace("bt.BTApp::isSOticketIDReady::tab", tab );
		//trace("bt.BTApp::isSOticketIDReady::errorstab", errorstab );
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
		var ddIsInit:Bool = details_product_dropdown.text == "details_dropdown_prompt".T() ;
		validatorDictionary.set(details_product_dropdown,
		{
			order: 3,
			label: details_product_label,
			alert: details_product_dropdown_alert.T(),
			value: v == null || ddIsInit ? "": v.value,
			ready: v != null && !ddIsInit
		}
							   );
		//return _details_product_value != null;
	}
	function isToolReady():Void
	{
		//var _details_tools_value:DropDownItem = details_tools_dropdown.selectedItem;
		var v:DropDownItem = details_tools_dropdown.selectedItem;
		var ddIsInit:Bool = details_tools_dropdown.text == "details_dropdown_prompt".T() ;
		#if debug
		//trace(details_tools_dropdown.text);
		//trace("details_dropdown_prompt".T());
		#else
		#end
		validatorDictionary.set(details_tools_dropdown,
		{
			order: 5,
			label: details_tools_label,
			alert: details_tools_dropdown_alert.T(),
			value: v == null || ddIsInit ? "": v.value,
			ready: v != null && !ddIsInit
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
			//value: '"$v"'.lineFeedToHTMLbr(),
			value: Markdown.markdownToHtml(v),
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
			//value: '"$v"'.lineFeedToHTMLbr(),
			value: Markdown.markdownToHtml(v),
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
					//details_customer_so_textfield,
					details_person_selector_input_textarea,
					details_person_selector_display_tableview

				];
			case "catAgent_misbehaviour_attitude" :
				[
					//details_tools_dropdown,
					details_process_textfield,
					reasons_description_defect_textarea,
					reasons_description_fix_textarea,
					/*details_customer_id_textfield,*/
					//details_customer_so_textfield,
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
					'catAgent_answering_storeredirect'|
					'catAgent_answering_insuficientlangskills'|
					'catAgent_misbehaviour_winback'|
					'catAgent_misbehaviour_equipementticket'|
					'catAgent_answering_stateoftheart'|
					'catAgent_answering_wronginfo'|
					'catAgent_answering_wronginfocontract'|
					'catAgent_answering_wrongoto'|
					'catAgent_answering_wrongpp'|
					'catAgent_answering_wrongoption'|
					'catAgent_answering_wrongcaraactivation'|
					'catAgent_answering_noret' |
					'catAgent_misbehaviour_forcedcontract' |
					"catAgent_misbehaviour_noinfo"
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
	/*****************************************************
	/*****************************************************
	 * EVENTS
	/*****************************************************
	/*****************************************************/
	/**
	 *
	 * @param	e
	 */
	function onTreeChanged(e:UIEvent):Void
	{
		if (reasons_categories_tree.selectedNode == null) return;

		var selectedNode:TreeViewNode = reasons_categories_tree.selectedNode;

		if (selectedNode.numComponents == 1 )
		{
			_selectedCat = cast(selectedNode.data.value, String);
		}
		else{
			_selectedCat = "";
			reasons_categories_label.text = LocaleManager.instance.lookupString("{{reasons_categories_label}}");
		}
		Lambda.iter(allInteractiveComps, removeMandatoryClass);
		if (_selectedCat != "")
		{
			checkWhatToValidate();
			strictProcess = ["catProcess_dysfunction","catProcess_wrongdocumentation"].indexOf( _selectedCat)> -1;
			Lambda.iter(toValidate, addMandatoryClass);
		}
	}
	/**
	 *
	 * @param	e
	 */
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
	/**
	 *
	 * @param	many
	 * @param	rejected
	 * @param	leavers
	 */
	function onManyFound(many:Array<Actor>, rejected:Array<String>, leavers:Array<Actor>):Void
	{
		//if (rejected.length > 0 || notFound > 0)
		var noTL:Array<String> = [];

		var leaversNts = Lambda.map(leavers,(e)->(e.sAMAccountName));
		if (rejected.length > 0 )
		{
			var stores = Lambda.filter(
				rejected,
				(e:String)->(return e.toLowerCase().indexOf("sst_") == 0)
			);
			var indirects = Lambda.filter(
				rejected,
				(e:String)->(return ExpReg.SAP_DEALER_CODE.STRING_TO_REG().match(e) && Lambda.exists(external_dealers, (r)->(r[0] == e)))
			);
			if (stores.length > 0)
			{
				rejected = Lambda.filter(
					rejected,
					(e:String)->(return e.toLowerCase().indexOf("sst_") != 0)
				);

				many = Lambda.concat(many, Lambda.map(stores, mapStoresEmailToActor));
			}
			if (indirects.length > 0)
			{
				rejected =  Lambda.filter(
								rejected,
								(e:String)->( return !(ExpReg.SAP_DEALER_CODE.STRING_TO_REG().match(e) && Lambda.exists(external_dealers, (r)->(r[0] == e))))
							);
				many = Lambda.concat(many, Lambda.map(indirects, mapIndirect));
			}
		}

		if (rejected.length > 0 || leaversNts.length > 0 ) showErrorDialog( rejected, leaversNts );

		details_person_selector_display_tableview.dataSource.clear();
		details_person_selector_display_label.text = "details_person_selector_display_label".T();
		details_person_selector_display_tableview.hidden = false;

		for ( i in many)
		{
			if (i.manager == null || i.manager.mbox == "")
			{
				if (i.getSimpleEmail() != "")
				{
					noTL.push(i.getSimpleEmail() + " (" + i.description+")");
				}
			}
			else
			{
				var tableItem:TableViewItem =
				{
					selected:false,
					mail: i.mbox.substr(7),
					tl: i.manager.mbox.substr(7),
					actor:i
				};
				details_person_selector_display_tableview.dataSource.add(tableItem) ;
			}

		}
		if (noTL.length > 0 )
		{
			showErrorDialog(noTL, [], true);

			var listToSend = noTL.filter((e)->(globalNoTL.indexOf(e) == -1));

			if (listToSend.length > 0)
			{
				globalNoTL = globalNoTL.concat(listToSend);
				debugMail.setSubject("[Better together Error] TLs not found for some users");
				var body = "Hi Better Together,<br/>";
				body += "I tried to submit a feedback, but looks like the manager(s) of  : <br/>" ;
				body += listToSend.join(".<br/>");
				body += ".<br/>cannot be found in the system.<br/><br/><em>Automatically generated by the app with the help of " + monitoringData.coach.name + "</em>";
				debugMail.setBody(body);
				debugMail.setCc([monitoringData.coach.getSimpleEmail()]);
				debugMail.send(true);

			}

		}

	}

	// BASE EVENTS
	override function onSend(e)
	{
		//super.onSend(e);
		if (checkMandatoriesValues())
		{
			var msg:MessageBox = new MessageBox();
			msg.type = MessageBoxType.TYPE_YESNO;
			msg.title = "warn_several_cases_title".T();
			msg.messageLabel.htmlText = "warn_several_cases_message".T();
			msg.width = 500;
			msg.onDialogClosed = (e:DialogEvent)->(if (e.button == DialogButton.YES) doTracking());

			if (validatorDictionary.get(details_person_selector_display_tableview).value.length > 1 &&
					(validatorDictionary.get(details_customer_id_textfield).value.length > 1 ||
					 validatorDictionary.get(details_customer_so_textfield).value.length > 1))
			{
				msg.showDialog(true);
			}
			else
			{
				doTracking();
			}
		}
	}
	override function onMailSucces(r:Result)
	{
		debounce = true;
		mailsToSend--;
		if (mailsToSend == 0)
		{
			storingBT.message = "EMAIL_SENT_SUCCESFULLY".T();
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
		if (success)
			sendEmail();
		else
		{
			#if debug
			//trace("bt.BTApp::onTracking NO SUCCESS");
			sendEmail();
			#end
		}
	}
	/**
	 * Capture lang change events
	 * @param	e
	 */
	override function onLangChanged(e:UIEvent)
	{
		super.onLangChanged(e);
		initCatTree(true);
	}

}
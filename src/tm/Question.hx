package tm;

import AppBase;
import Utils;
import haxe.Exception;
import haxe.Json;
import haxe.ui.components.Image;
import haxe.ui.components.Label;
import haxe.ui.components.OptionBox;
import haxe.ui.components.TextArea;
import haxe.ui.containers.Box;
import haxe.ui.containers.Group;
import haxe.ui.containers.HBox;
import haxe.ui.containers.VBox;
import haxe.ui.core.Component;
import haxe.ui.events.FocusEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.locale.LocaleManager;
import haxe.ui.styles.animation.Animation;
import tm.Agreement;
import xapi.types.Score;

/**
 * ...
 * @author bb
 */
/*enum Criticality{
	business;
	compliance;
	user;
	none;
}*/
typedef Userdata =
{
	var points: Int;
	var criticality: String;
	var critical: Bool;
}
class Question
{
	static inline var NON_CRITICAL:String = "non critical";
	public static inline var MIN_PERCENTAGE_BEFORE_FAILLING:Float = .8499; /**@TODO obsolete*/
	public static var HASTwoFailedInATopic:Bool;
	public static var TOTAL_FAILED:Float;
	public static var TM_PASSED:Bool = true;
	public static var SCORE = new Score();
	public static var ALL:Map<String,Question> = [];
	public static var COUNT:Int = 0;
	public static var MAX_SCORE:Int = 0;
	public static var FAILED_OVERALL:Array<String> = [];
	public static var FAILED_CRITICAL:Array<String> = [];
	public static var RESULT_MAP:Map<String,String> = [];
	public static var CRITICALITY_MAP:Map<String,Int> = ["business"=>0,"compliance"=>0,"customer"=>0];
	public static var INFO:tm.Info;
	

    /////////////////////////////////////////////////////////////////////
	////////////////////////// STATIC ///////////////////////////////////
	/////////////////////////////////////////////////////////////////////
	public static function GET_ALL(form:Component)
	{
		ALL = [];
		COUNT = 0;
		/*SCORE.reset();
		FAILED_OVERALL = [];
		FAILED_CRITICAL = [];
		
		MAX_SCORE = 0;
		TM_PASSED = true;
		TOTAL_FAILED = 0;
		HASTwoFailedInATopic = false;*/
		//var qs:Array<VBox> = form.findComponents("questions", VBox);
		var qs:Array<HBox> = form.findComponents("questions", HBox);
		var id = "";
		for (q in qs)
		{
			id = Utils.GET_PARENT_PATH(q, q.id);
			if (id == "") continue;
			
			ALL.set(id, new Question(id, q ));
			
			COUNT++;
		}


	}
	
	public static function RESET()
	{
		SCORE.reset();
		INFO.reset();
		ALL = [];
		COUNT = 0;
		SCORE.reset();
		FAILED_OVERALL = [];
		FAILED_CRITICAL = [];
		
		MAX_SCORE = 0;
		TM_PASSED = true;
		TOTAL_FAILED = 0;
		HASTwoFailedInATopic = false;
		CRITICALITY_MAP = ["business" => 0, "compliance" => 0, "customer" => 0];
		for (i in ALL)
		{
			i.reset();
		}
	}
	public static function GET_SCORE()
	{
        var failedTopic = new Map<String, Int>();
		var t = "";
		var t2 = [];
		TOTAL_FAILED = 0;
		HASTwoFailedInATopic = false;
		for (i in FAILED_OVERALL)
		{
			//totalFailed += ALL.get(i).userData.points;
			TOTAL_FAILED++;
			t2 = i.split(".");
			t = t2[t2.length - 2];
			if (failedTopic.exists(t)){
				failedTopic.set(t, failedTopic.get(t) + 1);
				HASTwoFailedInATopic = true;
			}
			else{
				failedTopic.set(t, 1);
			}
		}
		#if debug
		trace("Question::GET_SCORE::failedTopic", failedTopic );
		#end
		var count = 0;
		for (c in FAILED_CRITICAL)
		{
			var cc = ALL.get(c).userData.criticality;
			
			count = CRITICALITY_MAP.get(cc);
			
			CRITICALITY_MAP.set(cc, count +1);
		}

		/*if ( FAILED_CRITICAL.length > 0)
		{
			SCORE.max = 100;
			SCORE.raw = 0;
		}else{
			SCORE.raw = MAX_SCORE-totalFailed;
			SCORE.max = MAX_SCORE;
		}*/
		if ( FAILED_CRITICAL.length > 0 || TOTAL_FAILED > 2 || HASTwoFailedInATopic )
		{
			TM_PASSED = false;
		}
		//SCORE.max = 100;
		SCORE.raw = 100;
		if (FAILED_CRITICAL.length > 0)
		{
			
			SCORE.raw = 0;
		}else if(TOTAL_FAILED == 1 ){
			//SCORE.max = 100;
			SCORE.raw = 95;
		}else if(TOTAL_FAILED == 2 && !HASTwoFailedInATopic ){
			//SCORE.max = 100;
			SCORE.raw = 90;
		}
		else if (TOTAL_FAILED > 2 || HASTwoFailedInATopic)
		{
			SCORE.raw = 50;
		}
		// one critical -> failed
		// 2 in same 
		//return s;
	}
	/*public static MAP_ALL(extPrefix:String)
	{
		var m = [];
		for (k => v in ALL)
		{
			m.set('$extPrefix/$k', v);
		}
		return m;
	}*/
	public static function PREPARE_RESULTS():Utils.Status
	{
		var canSubmit = true;
		var m:Array<String> = [""];
		var mustJustify = false;
		//var completed = true;
		RESULT_MAP = [];
		for (k => v in ALL)
		{
			if (v.agreement.choice == "TODO")
			{
				canSubmit = false;
				m.push("{{ALERT_UNANSWERED_QUESTIONS}}");
				break;
			}
			else if (v.agreement.choice == "n")
			{
				if (v.justification.text == null || v.justification.text == "" )
				{
					mustJustify = true;
					v.justification.addClass("wrong");
				}
			}
			v.agreement.justification = v.justification.text;
			RESULT_MAP.set(k, v.agreement.choice);
			RESULT_MAP.set(k + ".justification", v.agreement.justification);

		}
		if (mustJustify)
		{
			m.push( "{{ALERT_ADD_ARGUEMENT_WHEN_DISAGREE}}");
			canSubmit = false;
		}
		if ( canSubmit ) GET_SCORE();
		
		return {canSubmit:canSubmit, messages: m};
	}
	static function RESET_Pointers()
	{
		for (v in ALL)
		{
			v.resetPointer();
		}
	}
	/////////////////////////////////////////////////////////////////////
	////////////////////////// OBJECT ///////////////////////////////////
	/////////////////////////////////////////////////////////////////////
	var label:Label;
	var radioGroup:Group;
	var justification:TextArea;
	var radioBtns:Array<OptionBox>;
	var id:String;
	var _this:Box;
	public var userData:Userdata;
	var infoIcon:Image;
	
	//var pointerIcon:Image;
	public var agreement(get, null):tm.Agreement;
	function new(id:String, parent:HBox)
	{
		//this.parent = parent;

		this.id = id;
		_this = parent;

		//trace(_this.styleNames);
		//trace(_this.cssName);
		//trace(id, _this.userData);
		userData = {points:5, critical:false, criticality:NON_CRITICAL};
		if ( _this.userData != null )
		{
			var ud:Dynamic = Json.parse( _this.userData);
			try
			{
				ud.critical = ! (ud.criticality == NON_CRITICAL);
				userData = ud;
			}
			catch (e)
			{
				trace('Wrong format for userdata $ud');
			}
			//userData.points = _this.userData.points;
			//userData.critical = false;
			//userData.criticality = "none";
		}
		//infoIcon = _this.findComponent("iconInfo", Image);
		//infoIcon.resource = "images/info-" + (userData.critical ? "critical.png":"noncritical.png");
		//infoIcon.onClick = updateInfo;

		label = _this.findComponent("question", Label);
		label.onClick = updateInfo;
		//label.registerEvent(MouseEvent.MOUSE_OVER, function(e)trace(e));
		label.htmlText = "{{" + this.id + "}}";
		//label.htmlText = "123456789123456789";
		radioGroup = _this.findComponent("agreement");
		//critical = radioGroup.hasClass("critical");
		radioBtns = cast(radioGroup.childComponents);
		justification = _this.findComponent("justify", TextArea);
		agreement = new tm.Agreement(getSelected(),"", userData.critical);
		radioGroup.onChange = onchange;
		justification.registerEvent(FocusEvent.FOCUS_OUT, onJustifyOut);
		justification.registerEvent(FocusEvent.FOCUS_IN, onJustifyIn);
		reset();
		if (ALL.exists(this.id))
		{
			throw new Exception("Duplicate Question");
		}
		else
		{
			ALL.set(this.id, this);
			//MAX_SCORE += userData.points;
		}

	}
    public function reset()
	{
		
		FAILED_OVERALL.remove(id);
		FAILED_CRITICAL.remove(id);

		resetRadios();
		resetJustification();
		resetPointer();
	}
	function resetPointer()
	{
		//pointerIcon.hidden = true;
		if (this.label.hasClass("h3")) this.label.removeClass("h3");
	}
	function updateInfo(e:MouseEvent)
	{
		//trace(id);
		//var animOpt:AnimationOptions = {};
		//animOpt.duration = 100;
		//animOpt.delay = 1;
		//var anim:Animation = new Animation(INFO.container, animOpt);

		if (INFO.container.hidden || this.id != INFO.id)
		{
			RESET_Pointers();
			this.label.addClass("h3");
			//pointerIcon.hidden = false;
			INFO.show(this.id);

			INFO.title.htmlText = "{{" + id + "}}";
			INFO.setCriticality(userData.critical);
			//var criticalString = userData.critical ? this.userData.criticality.toUpperCase() : "NON CRITICAL";
			INFO.criticality.htmlText = "{{" + this.userData.criticality.toUpperCase() + "}}";
			INFO.points.htmlText = "(pts: {{" + this.userData.points + "}})";
			INFO.questionDesc.htmlText = "{{" + id + ".desc}}";
			INFO.passedDesc.htmlText = "{{" + id + ".passed}}";
			INFO.failedDesc.htmlText = "{{" + id + ".failed}}";
			LocaleManager.instance.language = "en";
			LocaleManager.instance.language = AppBase.lang;
		}
		//anim.run(()->trace("finished"));
	}

	function onJustifyIn(e:FocusEvent):Void
	{
		justification.removeClass("wrong");
		#if debug
		trace("Question::onJustifyIn:: onJustifyIn", justification.className );
		#end

	}

	function onJustifyOut(e:FocusEvent):Void
	{
		this.agreement.justification = justification.text;
		justification.removeClass("wrong");
		#if debug
		trace("Question::onJustifyOut:: onJustifyIn", justification.className );
		#end
	}

	function onchange(e:UIEvent)
	{
		//var o:OptionBox = cast(e.target);
		//this.agreement.choice = o.id;
		this.agreement.choice = cast(e.target, OptionBox).id;
		updateInfo(null);
		if (this.agreement.choice == "n")
		{
			this.justification.placeholder = "{{failed_placeholder}}";
			if (!FAILED_OVERALL.contains(id))
			{
				FAILED_OVERALL.push(id);
			}
			if (userData.critical && !FAILED_CRITICAL.contains(id))
			{
				FAILED_CRITICAL.push(id);
			}
		}

		else
		{
			if (this.agreement.choice == "na")
			{
				resetJustification();
			}
			else if (this.agreement.choice == "y")
			{
				//this.justification.placeholder = "Comment if you wish.";
				this.justification.placeholder = "{{passed_placeholder}}";
			}
			FAILED_CRITICAL.remove(id);
			FAILED_OVERALL.remove(id);
		}
	}

	function resetJustification()
	{
		justification.text = "";
		justification.placeholder = "";
		/*justification.hidden = true;*/
	}

	function getSelected()
	{
		var o:OptionBox;
		for (i in radioBtns)
		{
			o = cast(i);
			if (o.selected) return o.id;

		}
		return "TODO";
	}

	function resetRadios()
	{
		radioGroup.resetGroup();
		agreement = new tm.Agreement(getSelected(),"", userData.critical);
	}
	function get_agreement():tm.Agreement
	{
		return agreement;
	}

}
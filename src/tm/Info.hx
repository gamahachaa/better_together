package tm;
import haxe.ui.components.Image;
import haxe.ui.components.Label;
import haxe.ui.core.Component;

/**
 * ...
 * @author bb
 */
class Info 
{
	var closeBtn:Image;
	public var container:Component;
	public var id:String;
	public var passedDesc:Label;
	public var failedDesc:Label;
	public var questionDesc:Label;
	public var criticality:Label;
	public var points:Label;
	public var title:Label;

	public function new(info:Component) 
	{
		container = info;
		title = container.findComponent("topicTitle", Label);
		questionDesc = container.findComponent("questionDesc", Label);
		criticality = container.findComponent("criticality", Label);
		points = container.findComponent("points", Label);
		passedDesc = container.findComponent("passedDesc", Label);
		failedDesc = container.findComponent("failedDesc", Label);
		closeBtn = container.findComponent("closeInfo", Image);
		closeBtn.onClick = (e)->(reset());
		//trace(passedDesc.htmlText);
	}
	public function reset()
	{
		container.hidden = true;
		title.htmlText = "";
		questionDesc.htmlText = "";
		criticality.htmlText = "";
		points.htmlText = "";
		passedDesc.htmlText = "";
		failedDesc.htmlText = "";
	}
	public function setCriticality(isCritical:Bool)
	{
		criticality.removeClass("critical");
		criticality.removeClass("noncritical");
		  if (isCritical)
		  {
			  criticality.addClass("critical");
		  }
		  else {
			  criticality.addClass("noncritical");
		  }
	}
	
	public function show(id:String) 
	{
		 this.id = id;
		 container.hidden = false;
	}
	
}
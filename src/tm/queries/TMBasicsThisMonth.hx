package tm.queries;
import haxe.Json;
import mongo.Pipeline;
import mongo.comparaison.GreaterOrEqualThan;
import mongo.conditions.And;
import mongo.conditions.Or;
import mongo.stages.Match;
import mongo.stages.Project;
import mongo.xapiSingleStmtShortcut.ActorName;
import mongo.xapiSingleStmtShortcut.StmtTimestamp;
import mongo.xapiSingleStmtShortcut.VerbId;
import roles.Actor;
import thx.DateTime;
import thx.DateTimeUtc;
import xapi.Agent;
import xapi.Verb;
import xapi.types.ISOdate;

/**
 * ...
 * @author bb
 */
typedef BasicTM ={
	var ?_id:Int;
	var statement_id:String;
	var agent:String;
	var tm:String;
	var timestamp:String;
	var TMpassed:String;
	//var success:String;
}
class TMBasicsThisMonth extends QueryBase
{

	public var listOfAgents(default, set):Array<roles.Actor>;

	
	public function new(listOfAgents:Array<roles.Actor>)
	{
		super();
		this.listOfAgents = listOfAgents;

	}
	

	

	function set_listOfAgents(value:Array<roles.Actor>):Array<roles.Actor>
	{
		return listOfAgents = value;
	}
	override public function get_pipeline():Pipeline
	{
		//_now = DateTime.nowUtc();
		
		var firstOfTheMonth = new ISOdate('${_now.year}-${ StringTools.lpad(Std.string(_now.month),"0" ,2 )}-01T00:00:00.00Z');
	    trace("1");
		var m:Match = new Match(new Or([for (i in listOfAgents) new ActorName(i.name)]));
		var mv:Match = new Match(new VerbId(Verb.recieved.id));
		//var mDate:Match = new Match(new StmtTimestamp({"$gte": firstOfTheMonth}));
		var mDate:Match = new Match(new StmtTimestamp(new GreaterOrEqualThan(firstOfTheMonth)));
		var pipeline = new Pipeline([m, mv, mDate, project]);
		return pipeline;
	}
	//public function test()
	//{
		//trace("yo");
	//}
}
package bt;

//import haxe.Http;
import haxe.Json;
import lrs.Access;
import lrs.vendors.Connector;
import lrs.vendors.LLAccess;
import lrs.vendors.LearninLocker;
import mongo.queries.Agregator;
import roles.Actor;
//import xapi.Agent;


/**
 * ...
 * @author bb
 */
class BTAgregator extends Agregator
{
	//var tmsDirectReports:TMBasicsThisMonth;
	//var tmsMentored:TMMentored;             
	
    //public var signal(get, null):signal.Signal1<Array<Dynamic>>;
	public function new()
	{
		
        var ll = new LearninLocker("troubleshooting", "https://qast.salt.ch", "", "", "Basic YTM2Y2M3M2RhMmE4YTc5ZjIwYjM2ZTc1MDJjMTBlZDdlZWJlZTk4YjpjMmQzYjc5YzUyZTk0YTk5YzRlMjM5YTNkZTUyOWZmZDZhNjBkMmIw", aggregation_sync);
		super(new LLAccess(ll));

	}
	
	/*public function getBasicBTThisMonth(nt:String)
	{
		#if debug
		trace("http.Agregator::getBasicTMThisMonth::nt", nt );
		#end
		//tmsMentored;
		try
		{
			if (tmsMentored == null)
			{
				
				tmsMentored = new BTReviewd(nt);
			}
			else
			{
				
				tmsMentored.nt = nt;
			}
			fetch(tmsMentored);
		}
		catch(e)
		{
			trace(e);
		}

	}*/
	
	/*public function getDirectReportsTMThisMonth(list:Array<roles.Actor>)
	{
		#if debug
		trace("http.Agregator::getBasicTMThisMonth::list", list );
		#end
		tmsDirectReports;
		try
		{
			if (tmsDirectReports == null)
			{
				tmsDirectReports = new tm.queries.TMBasicsThisMonth(list);
				trace("all good");
				//onData = tmBasics.onData;
			}
			else
			{
				tmsDirectReports.listOfAgents = list;
			}
			#if debug
			trace("http.Agregator::getDirectReportsTMThisMonth::Json.stringify(tmsDirectReports.pipeline)", Json.stringify(tmsDirectReports.pipeline) );
			#end
			 fetch(tmsDirectReports);
		}
		catch(e)
		{
			trace(e);
		}

	} */
	


}
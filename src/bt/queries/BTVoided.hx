package bt.queries;

import mongo.Pipeline;
import mongo.conditions.And;
import mongo.queries.QueryBase;
import mongo.stages.Match;
import mongo.xapiSingleStmtShortcut.ObjectId;
import mongo.xapiSingleStmtShortcut.ObjectId;
import mongo.xapiSingleStmtShortcut.ObjectType;
import xapi.types.IObject.ObjectTypes;

/**
 * ...
 * @author bb
 */
class BTVoided extends QueryBase
{
	var voidedId:String;

	public function new(voidedId:String)
	{
		super(
		{
			"_id": 1,
			"id": "$statement.id",
			"voided_id": "$statement.object.id",
			"who": "$statement.actor.name",
			"when": "$stored",
			"cat": "$statement.context.extensions.https://qook&46;salt&46;ch/better_together/reasons_categories"
		}, false);
        this.voidedId = voidedId;
		
	}
	override public function get_pipeline():Pipeline
	{
       var m:Match = new Match(
			new And([
				 new ObjectId(this.voidedId),
				 new ObjectType(StatementRef)
			])
	   );
	   return pipeline = new Pipeline(
		[m, project]
	   );
	}
}
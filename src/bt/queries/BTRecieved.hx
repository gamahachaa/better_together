package bt.queries;

import mongo.queries.QueryBase;

/**
 * ...
 * @author bb
 */
class BTRecieved extends QueryBase 
{

	public function new(nt:String,?previousMonth:Bool=false) 
	{
		super({
			{
			_id:0,
			statement_id:"$statement.id",
			when:"$stored",
			category:"",
			what_happened:"$statement.actor.name",
			how_should_it_be:"$statement.actor.name",
			customer:"$statement.object.id",
			so_ticket:"$statement.timestamp",
			process:"$statement.result.success",
			tool:"$statement.result.success"
		}
		}, previousMonth);
		
	}
	
}
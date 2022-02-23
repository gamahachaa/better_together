package tm;

/**
 * ...
 * @author bb
 */
class Agreement 
{
	public var choice:String;
	public var justification:String;
	public var critical:Bool;
	public function new(?choice:String="", ?justification:String="", ?critical:Bool= false) 
	{
		this.choice = choice;
		this.justification = justification;
		this.critical = critical;
	}
	
}
package;

/**
 * ...
 * @author bb
 */
class BTAppNew extends AppBase 
{

	public function new(mailerClass:Class<MailHelper>, xapiHelper:Class<XapiHelper>, appName:String, ?mainUserDirectRports:Bool=false, ?trackLogin:Bool=false) 
	{
		super(mailerClass, xapiHelper, appName, mainUserDirectRports, trackLogin);
		
	}
	
}
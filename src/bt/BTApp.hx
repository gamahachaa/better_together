package bt;

/**
 * ...
 * @author bb
 */
class BTApp extends AppBase 
{

	public function new( ) 
	{
		super(BTMailer, BTTracker);
		this.whenAppReady = loadContent;
		
		app.ready(onAppReady);
	}
	
	function loadContent() 
	{
		trace("started");
		if (loginApp != null) app.removeComponent(loginApp);
		this.mainApp = ComponentMacros.buildComponent("assets/ui/main.xml");
	}
	
}
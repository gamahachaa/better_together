package;
import bt.BTMailer;
import bt.BTTracker;
import haxe.ui.Toolkit;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.styles.Parser;
import views.MainView;


/**
 * ...
 * @author bb
 */
class BTAppNew extends AppBase
{

	public function new( )
	{
		Toolkit.theme = "dark";
        Toolkit.styleSheet.parse("assets/css/main.css");
		//super(BTMailer, BTTracker, "better_together");
		super("better_together");
		//allSelected = false;
		this.whenAppReady = loadContent;
		this.setAppComponents(BTMailer, BTTracker, MainView);
		//initImage();
		init();
		//justLoaded = true;
		//globalNoTL = [];

	}
	/*override function loadContent()
	{
		this.mainApp = new MainView();
		app.addComponent( mainApp );
	}*/
	
}
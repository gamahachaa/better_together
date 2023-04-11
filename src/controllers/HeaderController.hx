package controllers;
import views.Header;

/**
 * ...
 * @author bb
 */
class HeaderController 
{
	var headerView:Header;

	public function new(headerView:Header) 
	{
		this.headerView = headerView;
		this.headerView.signalLogoff.add(()->(trace("Bound")));
		
	}
	
	
}
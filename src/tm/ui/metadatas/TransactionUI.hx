package tm.ui.metadatas;

import haxe.ui.containers.VBox;
import haxe.ui.events.UIEvent;
import signals.Signal1;
using StringTools;

/**
 * ...
 * @author bb
 */
@:build(haxe.ui.macros.ComponentMacros.build("assets/ui/metadatas/Transaction.xml"))
class TransactionUI extends VBox
{
	var date:Date;
	public var formSignal(get, null):signals.Signal1<String>;
	public var dateSignal(get, null):signals.Signal1<Date>;
	public var searchAgentSignal(get, null):Signal1<String>;

	/////////////////// PUBLIC //////////////////
	public function new()
	{
		super();
		searchAgentSignal = new Signal1<String>();
		dateSignal = new Signal1<Date>();
		formSignal = new Signal1<String>();
		formSwitcher.onChange = (e:UIEvent)->(trace(e.target.id));
		//formSwitcher.onChange = (e:UIEvent)->(trace(e.target.id),formSignal.dispatch(e.target.id));
		agentBtn.onClick = (e)->(searchAgentSignal.dispatch(agentNt.text));
		TRANSACTION_WHEN.onChange = onDateChange;
		TRANSACTIONWHENHOURS.onChange = onDateChange;
		TRANSACTION_WHEN_MINUTES.onChange = onDateChange;
	}
	
	function onDateChange(e:haxe.ui.events.UIEvent) 
	{
		prepareTransactionDate();
	}
	public function validateData()
	{
		var canSubmit = true;
		var message = [""];
		if (transactionID.text == null || transactionID.text.trim() == "")
		{
			canSubmit = false;
			message.push("{{ALERT_TRANSACTION_ID_NOT_SET}}");
		}
		if (agentNt.text == null || agentNt.text.trim() =="")
		{
			canSubmit = false;
			message.push("{{ALERT_AGENT_NOT_SEARCHED}}");
		}
		if (date == null || date.getFullYear() == 2000)
		{
			canSubmit = false;
			message.push("{{ALERT_TRANSACTION_DATE_NOT_SET}}");
		}
		if (transactionsummary.text == null || transactionsummary.text.trim() == "")
		{
			canSubmit = false;
			message.push("{{ALERT_TRANSACTION_SUMMARY}}");
		}
		return {canSubmit:canSubmit, message: message};
	}
	
	/////////////////// PRIVATE //////////////////
	function prepareTransactionDate()
	{
		var tmp = cast(TRANSACTION_WHEN.value, Date);
		if (tmp != null)
		{
			tmp = Date.fromTime(tmp.getTime() + (TRANSACTIONWHENHOURS.value * 3600000) + (TRANSACTION_WHEN_MINUTES.value * 60000));
		}
		date = tmp;
		//trace(tmp);
		//trace(transactionDate);
		dateSignal.dispatch(date);
	}
	/*********************************************/
	function get_dateSignal():signals.Signal1<Date> 
	{
		return dateSignal;
	}
	
	function get_formSignal():signals.Signal1<String> 
	{
		return formSignal;
	}
	
	function get_searchAgentSignal():Signal1<String>
	{
		return searchAgentSignal;
	}
}
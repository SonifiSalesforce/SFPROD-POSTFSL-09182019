trigger StandardServiceAppointmentTrigger on ServiceAppointment (before insert, before update, after insert, after update) {

    //jjackson--check to see if trigger is turned off via the custom setting
    try{ 
    	if(AppConfig__c.getValues('Global').BlockTriggerProcessing__c) {
    		return;
    	} else if(ServiceAppointmentTriggerConfig__c.getValues('Global').BlockTriggerProcessing__c) {
			return; 
		}
    }
    catch (Exception e) {}

if(trigger.isBefore)
{

    if(trigger.isUpdate)
    {
        StandardServiceAppointmentTriggerLogic.ChangeScheduledEndDatetoActual(trigger.new, trigger.oldMap);
    }
}

if(trigger.isAfter)
{
    if(trigger.isUpdate)
    {
        StandardServiceAppointmentTriggerLogic.PopulateFWODatefromSA(trigger.new, trigger.oldMap);
    }
}

}
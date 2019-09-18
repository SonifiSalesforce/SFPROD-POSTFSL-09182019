/*  
    jjackson 8/2019 BUG-00916 Change SA scheduled end time to the actual end time (check-out date/time)
    jjackson 8/2019 BUG-00905 Post-FSL update FWO date from related Service Appointment
    
    Joan Jackson
    Sonifi Solutions
    8/13/2019
*/
public with sharing class StandardServiceAppointmentTriggerLogic {

    public static void PopulateFWODatefromSA(List<ServiceAppointment> lsttriggersa, Map<Id,ServiceAppointment> trigoldmap)
    {
        system.debug('*************BEGIN Populate FWODatefromSA**************');

        Map<Id,WorkOrder> mpfwo = New Map<Id,WorkOrder>();
        List<WorkOrder> lstupdfwo = New List<WorkOrder>();
        Set<Id> setfwoid = New Set<Id>();

        for(ServiceAppointment s  :lsttriggersa)
        {
                if(s.ParentRecordId != null && string.valueof(s.ParentRecordId).startsWith('0WO'))
                {  setfwoid.add(s.parentrecordid); }
        }

        for(WorkOrder w : [Select Id, Date__c from WorkOrder where id in :setfwoid])
        {   mpfwo.put(w.id, w); }


        if(trigoldmap != null)
        {
            for(ServiceAppointment sa :lsttriggersa)
            {
                
                {
                    if(trigoldmap.get(sa.id).actualstarttime == null && sa.actualstarttime != null ||
                       trigoldmap.get(sa.id).actualstarttime != sa.actualstarttime)
                    {
                        if(mpfwo.containskey(sa.parentrecordid))
                        {
                            WorkOrder wo = new WorkOrder();
                            wo = mpfwo.get(sa.parentrecordid);
                            wo.date__c = sa.actualstarttime;
                            lstupdfwo.add(wo);
                        }
                    }
                }
            }

            if(lstupdfwo.size() > 0)
            {
                try{ update lstupdfwo; }
                catch(Exception e)
                {
                    system.debug('ERROR updating FWO Date from SA actualstarttime: ' +e.getmessage());
                }
            }
        }

        system.debug('***************END PopulateFWODatefromSA**************** ');

    }//end PopulateFWODatefromSA

    public static void ChangeScheduledEndDatetoActual(List<ServiceAppointment> lsttriggernew, Map<Id,ServiceAppointment> trigoldmap)
    {
        for(ServiceAppointment s :lsttriggernew)
        {
            if(s.actualendtime != null && s.sonifi_work_order__c == null)
            {
                if(s.actualendtime != trigoldmap.get(s.id).actualendtime)
                {
                    s.schedendtime = s.actualendtime;
                }

            }
        }
    }

}
@isTest
public without sharing class StandardServiceAppointmentTrigLogicTest {
    
    
    static testmethod void PopulateFWODateTest() 
    {
		//Sample code create service appointment with work type, etc.

        Case newcase = CreateTestRecords.DefaultSupportCase();
		
        Id accid = newcase.accountid;
        WorkOrder testwo = CreateTestRecords.DefaultFieldServiceWO(accid,newcase.id);
		


        //jjackson now create all the data that is needed for a service appointment
        Profile proid = [Select id, name from Profile where name = 'System Administrator' LIMIT 1];
		User u = New User(alias='jblow', firstname='Joe', lastname='Blow', email='testemail@invalid.com',
		                  username='testemail@invalid.com', profileid = proid.id, timezonesidkey='America/Chicago', isActive=true,
						  localesidkey='en_US', languagelocalekey='en_US', emailencodingkey='ISO-8859-1', currencyisocode='USD',
						  defaultcurrencyisocode='USD');
		insert u;



		ServiceResource sr = New ServiceResource(Name='Joe Blow', relatedrecordid=u.id, 
		                     isActive = true, resourcetype='T');
		insert sr;

		OperatingHours oh = New OperatingHours(Name='Regular Time = Central Time - US', Timezone='America/Chicago');
		insert oh;

		ServiceTerritory st = New ServiceTerritory(Name='Test Territory', City = 'Sioux Falls', CurrencyIsoCode = 'USD', GeocodeAccuracy='Zip', IsActive=True,
							  postalcode = '57106', State='SD', operatinghoursid=oh.id);
		insert st;

		WorkType wt = New WorkType(Name='Interactive', durationtype='Hours', estimatedduration=2,
		                           work_type_category__c = 'Dispatch', ownerid=u.id);
		insert wt;

		newcase.Target_Date_Time__c = system.now().addDays(4);
		newcase.Work_Type__c = wt.id;
		newcase.Service_Territory__c = st.id;
		update newcase;

		testwo.WorkTypeId = wt.id;
		testwo.ServiceTerritoryId = st.id;
		update testwo;

		DateTime setactual = system.now().addminutes(30);

		ServiceAppointment svcapp = New ServiceAppointment(case__c = newcase.id, schedstarttime=system.now().addminutes(-60), 
                                    schedendtime=system.now().addminutes(90), technician_assigned__c = sr.id,
									sa_type__c = 'Dispatch', field_work_order__c = testwo.id, subject = 'test',
									serviceterritoryid=st.id, parentrecordid=testwo.id, status = 'Scheduled',
                                    account_name__c = newcase.accountid, duedate = system.now().adddays(3));
		insert svcapp;

        test.startTest();

        ServiceAppointment sa = [ Select Id, schedendtime, actualstarttime, actualendtime from ServiceAppointment LIMIT 1 ];

        sa.actualstarttime = setactual;
        update sa;

        WorkOrder wo = [ Select Id, Date__c from WorkOrder where id = :testwo.id];
		system.assert(wo.date__c != null);


		DateTime setactualend = system.now().addminutes(60);
		sa.actualendtime = setactualend;
		update sa;

		ServiceAppointment updsa = [Select id, schedendtime, actualendtime from ServiceAppointment LIMIT 1];

		system.assert(sa.schedendtime != updsa.schedendtime);

        test.stopTest();





    }

}
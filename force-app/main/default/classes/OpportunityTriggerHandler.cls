/*
* @author : Mani Mahal
* @date : September 29, 2022
*
* @description : Trigger Handler on Opportunity that automatically adds contact roles to Opportunitues for all the Contacts 
*                on account; based on a filter when Opportunity is Closed/Won.
*/

public class OpportunityTriggerHandler { 

    public static final String OPPORTUNITY_STAGENAME = 'Closed Won';

    public static void addContactRolesOpportunityOnUpdate(List<Opportunity> newOpportunitues, Map<Id, Opportunity> oldMapOpportunitues) {
        // make this modular 

        Map<Id, List<Id>> mapAccountIdWithOppIds = new Map<Id, List<Id>>(); 

        for(Opportunity newOpp: newOpportunitues) {
            Opportunity oldOpp = oldMapOpportunitues.get(newOpp.id);
            if(oldOpp.StageName !=OPPORTUNITY_STAGENAME && newOpp.StageName == OPPORTUNITY_STAGENAME) {
                if(mapAccountIdWithOppIds.containsKey(newOpp.AccountId)) {
                    List<Id> oppIds = new List<Id>();
                    oppIds = mapAccountIdWithOppIds.get(newOpp.AccountId);
                    oppIds.add(newOpp.Id);
                    mapAccountIdWithOppIds.put(newOpp.AccountId, oppIds);
                } else {
                    mapAccountIdWithOppIds.put(newOpp.AccountId, new List<Id> { newOpp.Id });
                }
            }
        }

        if(mapAccountIdWithOppIds == null || mapAccountIdWithOppIds.isEmpty()) {
            return; 
        }

        //get Account Contact details
        Map<Id, List<Contact>> mapAccountIdWithContacts = new Map<Id, List<Contact>>();
        List<OpportunityContactRole> newOppContactRole =  new List<OpportunityContactRole>();

        for(Account acc: [SELECT Id, Name, (SELECT Id, LastName FROM Contacts) FROM Account WHERE Id IN:mapAccountIdWithOppIds.keySet()]) {
            mapAccountIdWithContacts.put(acc.Id, acc.Contacts);
        }

        for(Id accIdValue : mapAccountIdWithOppIds.keySet()) {
            for(Contact con : mapAccountIdWithContacts.get(accIdValue)) { 
                for(Id oppIdValue : mapAccountIdWithOppIds.get(accIdValue)) {
                    OpportunityContactRole ocr = createOpportunityContactRole(
                        oppIdValue, 
                        con.id, 
                        'Family Member', 
                        FALSE,
                        FALSE
                     );
                    newOppContactRole.add(ocr);
                }
            }
        }

        if(newOppContactRole.isEmpty()) {
            return;
        }

        try {
            insert newOppContactRole;
        } catch(DmlException e) {
            //@todo Send an email or append to a logging mechanism
            System.debug('The following exception has occurred: '+e.getMessage());
        }
    }

	private static OpportunityContactRole createOpportunityContactRole(Id opportunityId, Id contactId, String role, Boolean isPrimary, Boolean doInsert) {
        OpportunityContactRole c = new OpportunityContactRole(
            OpportunityId = opportunityId, 
            ContactId = contactId, 
            Role = role, 
            IsPrimary = isPrimary);

		if(doInsert) {
			insert c;
		}
		return c;
	}
}
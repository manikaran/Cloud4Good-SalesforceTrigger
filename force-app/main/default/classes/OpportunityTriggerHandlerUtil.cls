/*
* @author : Mani Mahal
* @date : September 29, 2022
*
* @description : Trigger Handler Utility Class
*/

public class OpportunityTriggerHandlerUtil {

    /*
    * @description : Utility parent method to prepare staging data for contactRolesOpportunity
    *
    * @param : List of opportunities
    * @return : List of opportunityContactRole
    */
    public static List<OpportunityContactRole> addContactRolesOpportunity(List<Opportunity> newOpps) {
        if(newOpps.isEmpty()) return null; 

        Map<Id, List<Id>> mapAccountIdWithOppIds = createMapAccountIdWithOppIds(newOpps);
        Map<Id, List<Contact>> mapAccountIdWithContacts = createMapAccountIdWithContacts(mapAccountIdWithOppIds.keySet());
        List<OpportunityContactRole> newOppContactRoles = createNewOppContactRoles(mapAccountIdWithOppIds, mapAccountIdWithContacts);
        return newOppContactRoles;
    }

    /*
    * @description : Utility method to create a map of account id with its opportunity Ids 
    *
    * @param : List of opportunities
    * @return :  Map of accId, oppIds
    */
    public static Map<Id, List<Id>> createMapAccountIdWithOppIds(List<Opportunity> oppList) {
        if(oppList.isEmpty()) return null; 

        Map<Id, List<Id>> mapIdWithIds = new Map<Id, List<Id>>(); 
        for(Opportunity sObj: oppList) {
            if(mapIdWithIds.containsKey(sObj.AccountId)) {
                List<Id> secondaryIds = new List<Id>();
                secondaryIds = mapIdWithIds.get(sObj.AccountId);
                secondaryIds.add(sObj.Id);
                mapIdWithIds.put(sObj.AccountId, secondaryIds);
            } else {
                mapIdWithIds.put(sObj.AccountId, new List<Id> { sObj.Id });
            }

        }
        return mapIdWithIds;
    }

    /*
    * @description : Utility method to create a map of account id with its contact Ids 
    *
    * @param : List of accounts 
    * @return :  Map of accId, contactIds
    */
    public static Map<Id, List<Contact>> createMapAccountIdWithContacts(Set<Id> accIdList) {
        if(accIdList.isEmpty()) return null; 

        Map<Id, List<Contact>> mapIdwithIds = new Map<Id, List<Contact>>();
        for(Account acc: [SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE Id IN:accIdList]) {//DML limit check
            mapIdwithIds.put(acc.Id, acc.Contacts); // do I need the entire contact
        }
        return mapIdwithIds;
    }

    /*
    * @description : Utility method to create relationship between account, contact, opportunity data for OpportunityContactRole object
    *
    * @param : Map of accId and oppIds, Map of accId and contactIds 
    * @return : List of new OpportunityContactRole
    */
    public static List<OpportunityContactRole> createNewOppContactRoles(Map<Id, List<Id>> mapAccIdOppIds, Map<Id, List<Contact>> mapAccIdCons) {
        if(mapAccIdOppIds.isEmpty() || mapAccIdCons.isEmpty() ) return null; 
        List<OpportunityContactRole> newOppContactRolesList =  new List<OpportunityContactRole>();

        for(Id accId : mapAccIdOppIds.keySet()) {
            for(Contact con : mapAccIdCons.get(accId)) {
                for(Id oppId : mapAccIdOppIds.get(accId)) {
                    OpportunityContactRole ocr = createOpportunityContactRole(
                        oppId, 
                        con.id, 
                        'Family Member', 
                        FALSE,
                        FALSE
                     );
                    newOppContactRolesList.add(ocr);
                }
            }
        }
        return newOppContactRolesList;
    }

    /*
    * @description : Utility method for insert OpportunityContactRole object
    *
    * @param : OpportunityId, ContactId, Role, PrimaryFlag, doInsert Flag 
    * @return : OpportunityContactRole object
    */
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

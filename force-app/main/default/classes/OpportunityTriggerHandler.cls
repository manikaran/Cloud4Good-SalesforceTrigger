/*
* @author : Mani Mahal
* @date : September 29, 2022
*
* @description : Trigger Handler on Opportunity that automatically adds contact roles to Opportunitues for all the Contacts 
*                on account; based on a filter when Opportunity is Closed/Won.
*/

public class OpportunityTriggerHandler {

    public static final String OPPORTUNITY_STAGENAME = 'Closed Won';

    /*
    * @description : Add new Contact Roles to Opportunities On Update Trigger
    *
    * @param : List of new opportunities, List of old opportunities
    */
    public static void addContactRolesOpportunityOnUpdate(List<Opportunity> newOpportunitues, Map<Id, Opportunity> oldMapOpportunitues) {

        List<Opportunity> newClosedWonOpportunitues = new List<Opportunity>();

        for(Opportunity newOpp: newOpportunitues) {
            Opportunity oldOpp = oldMapOpportunitues.get(newOpp.id);
            if(oldOpp.StageName !=OPPORTUNITY_STAGENAME && newOpp.StageName == OPPORTUNITY_STAGENAME) {
                newClosedWonOpportunitues.add(newOpp);
            }
        }
        if(newClosedWonOpportunitues == null || newClosedWonOpportunitues.isEmpty()) {
            return;
        }

        List<OpportunityContactRole> newOppContactRoles = OpportunityTriggerHandlerUtil.addContactRolesOpportunity(newClosedWonOpportunitues);
        if(newOppContactRoles == null || newOppContactRoles.isEmpty()) {
            return;
        }

        try {
            insert newOppContactRoles; // Check DML limits while inserting, AllOrNone vs and Database.insert
        } catch(DmlException e) {
            //@todo Append to a logging mechanism
            System.debug('The following exception has occurred: '+e.getMessage());
        }
    }

    /*
    * @description : Add new Contact Roles to Opportunities On Insert Trigger
    *
    * @param : List of new opportunities 
    */
    public static void addContactRolesOpportunityOnInsert(List<Opportunity> newOpportunitues) {

        List<Opportunity> newClosedWonOpportunitues = new List<Opportunity>();

        for(Opportunity newOpp: newOpportunitues) {
            if(newOpp.StageName == OPPORTUNITY_STAGENAME) {
                newClosedWonOpportunitues.add(newOpp);
            }
        }
        if(newClosedWonOpportunitues == null || newClosedWonOpportunitues.isEmpty()) {
            return;
        }

        List<OpportunityContactRole> newOppContactRoles = OpportunityTriggerHandlerUtil.addContactRolesOpportunity(newClosedWonOpportunitues);
        if(newOppContactRoles == null || newOppContactRoles.isEmpty()) {
            return;
        }

        try {
            insert newOppContactRoles; // Check DML limits while inserting, AllOrNone vs and Database.insert
        } catch(DmlException e) {
            //@todo Append to a logging mechanism
            System.debug('The following exception has occurred: '+e.getMessage());
        }
    }
}
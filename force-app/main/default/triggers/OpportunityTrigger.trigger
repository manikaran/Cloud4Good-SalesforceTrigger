/*
* @author : Mani Mahal
* @date : September 29, 2022
*
* @description : Opportunity Trigger
*/
trigger OpportunityTrigger on Opportunity (after insert, after update) {

    if(Trigger.isAfter) {
        if (Trigger.isInsert) {
            OpportunityTriggerHandler.addContactRolesOpportunityOnInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            OpportunityTriggerHandler.addContactRolesOpportunityOnUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}
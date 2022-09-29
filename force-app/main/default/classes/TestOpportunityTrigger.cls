/*
* @author : Mani Mahal
* @date : September 29, 2022
*
* @description : Test Class for Opportunity Trigger
*/
@isTest
public class TestOpportunityTrigger {

    public static final String TEST_ACCOUNT_NAME = 'TestAccountName';
    public static final String TEST_CONTACT_FIRSTNAME = 'TestContactFirstName';
    public static final String TEST_CONTACT_FIRSTNAME_2 = 'TestContactFirstName_2';
    public static final String TEST_CONTACT_FIRSTNAME_3 = 'TestContactFirstName_3';
    public static final String TEST_CONTACT_FIRSTNAME_4 = 'TestContactFirstName_4';

    @testSetup 
    static void testSetup() {
        Account testAccount = TestDataFactory.createAccount(TEST_ACCOUNT_NAME, true);
        Contact testContact = TestDataFactory.createContact(TEST_CONTACT_FIRSTNAME, testAccount.id, true);
        Contact testContact2 = TestDataFactory.createContact(TEST_CONTACT_FIRSTNAME_2, testAccount.id, true);
       // Contact testContact3 = TestDataFactory.createContact(TEST_CONTACT_FIRSTNAME_3, testAccount.id, true);
       // Contact testContact4 = TestDataFactory.createContact(TEST_CONTACT_FIRSTNAME_4, testAccount.id, true);
        List<Opportunity> testOpportunitiesProspecting = TestDataFactory.createOpportunity(testAccount.id, 4, 'Prospecting'); 
        insert testOpportunitiesProspecting;

    }

    //test on insert
    //test on update

    //test on no records
    // bulk test
    // governer limits test

    // actual role test in opp contact 
    // same opp update from closed one to closed one, it should fire but now make opp contact role again 
    // positive insert closed won then 3
    // negative insert prospecting then 3
    // how to test 20000 opportunity

    @isTest
    static void testOppOnUpdate() {
        List<Opportunity> opps = [SELECT Id, AccountId, StageName FROM Opportunity];
        System.debug('Initial testOppOnUpdate :'+opps);
        System.debug('Initial testOppOnUpdate size :'+opps.size());

        Test.startTest();
        for(Opportunity opp: opps) {
            opp.StageName = 'Closed Won';
        }
        update opps;
        Test.stopTest();

        List<OpportunityContactRole> oppConRoles = [SELECT OpportunityId, ContactId, Role, IsPrimary FROM OpportunityContactRole];
        System.debug('Opportunity Contact Role created  :'+oppConRoles);
        System.debug('Opportunity Contact Role created size  :'+oppConRoles.size());
        //WHERE OpportunityId IN: opps];
       // System.assertEquals(opps, opps, 'It has changed');
    }
}
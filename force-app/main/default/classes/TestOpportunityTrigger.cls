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
    public static final String TEST_OPPORTUNITY_STAGENAME_CLOSEWON = 'Closed Won';
    public static final String TEST_OPPORTUNITY_STAGENAME_PROSPECTING = 'Prospecting';

    @testSetup 
    static void testSetup() {
        Account testAccount = TestDataFactory.createAccount(TEST_ACCOUNT_NAME, true);
        Contact testContact = TestDataFactory.createContact(TEST_CONTACT_FIRSTNAME, testAccount.id, true);

        List<Contact> testContacts = TestDataFactory.createContacts(testAccount.id, 9);
        insert testContacts;

        List<Opportunity> testOpportunitiesProspecting = TestDataFactory.createOpportunity(testAccount.id, 4, TEST_OPPORTUNITY_STAGENAME_PROSPECTING); 
        insert testOpportunitiesProspecting;

        List<Opportunity> testOpportunitiesClosedWon = TestDataFactory.createOpportunity(testAccount.id, 4, TEST_OPPORTUNITY_STAGENAME_CLOSEWON); 
        insert testOpportunitiesClosedWon;
    }

    /*
    * @description : Test Opportunity Trigger on Update : Happypath 
    */
    @isTest
    static void testOppOnUpdate() {
        List<Opportunity> opps = [SELECT Id, StageName FROM Opportunity];
        List<Contact> contacts = [SELECT Id FROM Contact];

        Test.startTest();
        for(Opportunity opp: opps) {
            opp.StageName = TEST_OPPORTUNITY_STAGENAME_CLOSEWON;
        }
        update opps;
        Test.stopTest();

        List<OpportunityContactRole> oppConRoles = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId IN:opps];
        System.assertEquals((opps.size() * contacts.size()), oppConRoles.size(), 'Count matched on Update');
    }

    /*
    * @description : Test Opportunity Trigger on Insert : Happypath 
    */
    @isTest
    static void testOppOnInsert() {
        List<Account> acc = [SELECT Id FROM Account WHERE Name =:TEST_ACCOUNT_NAME LIMIT 1] ;
        List<Contact> contacts = [SELECT Id FROM Contact];
        List<Opportunity> opps = TestDataFactory.createOpportunity(acc[0].id, 4, TEST_OPPORTUNITY_STAGENAME_CLOSEWON); 

        Test.startTest();
        insert opps;
        Test.stopTest();

        List<OpportunityContactRole> oppConRoles = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId IN:opps];

        System.assertEquals((opps.size() * contacts.size()), oppConRoles.size(), 'Count matches on Insert');
    }

    /*
    * @description : Test Opportunity Trigger on Insert : when Stagename != Closed/Won, hence no OpportunityContactRoles created  
    */
    @isTest
    static void testOppOnNoRecordsOnInsert() {
        List<Account> acc = [SELECT Id FROM Account WHERE Name =:TEST_ACCOUNT_NAME LIMIT 1] ;
        List<Contact> contacts = [SELECT Id FROM Contact];
        List<Opportunity> opps = TestDataFactory.createOpportunity(acc[0].id, 4, TEST_OPPORTUNITY_STAGENAME_PROSPECTING); 

        Test.startTest();
        insert opps;
        Test.stopTest();

        List<OpportunityContactRole> oppConRoles = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId IN:opps];
        System.assertEquals(0, oppConRoles.size(), 'Count matches on Insert NoOppConRole');
    }

    /*
    * @description : Test Opportunity Trigger on Update : when old StageName and new StageName both are Closed/Won, hence no OpportunityContactRoles created  
    */
    @isTest
    static void testOppOnClosedWonOnUpdate() {
        List<Opportunity> opps = [SELECT Id, StageName FROM Opportunity WHERE StageName =: TEST_OPPORTUNITY_STAGENAME_CLOSEWON];
        List<Contact> contacts = [SELECT Id FROM Contact];
        List<OpportunityContactRole> oldOppConRoles = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId IN:opps];

        Test.startTest();
        for(Opportunity opp: opps) {
            opp.StageName = TEST_OPPORTUNITY_STAGENAME_CLOSEWON;
        }
        update opps;
        Test.stopTest();

        List<OpportunityContactRole> newOppConRoles = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId IN:opps];
        System.assertEquals(oldOppConRoles.size(), newOppConRoles.size(), 'Count matches on Update Closed Won(Same stagename update)');
    }

    /*
    * @description : Test Opportunity Trigger on Update : All Opportunity Contact Role should have Family Member
    */
    @isTest
    static void testOppRoleCheckOnUpdate() {
        List<Opportunity> opps = [SELECT Id, StageName FROM Opportunity WHERE StageName =: TEST_OPPORTUNITY_STAGENAME_PROSPECTING];
        List<Contact> contacts = [SELECT Id FROM Contact];

        Test.startTest();
        for(Opportunity opp: opps) {
            opp.StageName = TEST_OPPORTUNITY_STAGENAME_CLOSEWON;
        }
        update opps;
        Test.stopTest();

        List<OpportunityContactRole> newOppConRoles = [SELECT Id, Role FROM OpportunityContactRole WHERE OpportunityId IN:opps];

        Integer counterRole = 0;
        for(OpportunityContactRole opp: newOppConRoles) {
            if(opp.Role == 'Family Member') {
                counterRole++;
            }
        }

        System.assertEquals(counterRole, newOppConRoles.size(), 'Opportunity Contact Role Family member count match');
    }

    /*
    * @description : Test Opportunity Trigger on Update : Bulk Test
    */
    @isTest
    static void testBulkTestOnUpdate() {
        Account acc = TestDataFactory.createAccount(true);
        List<Opportunity> opps = TestDataFactory.createOpportunity(acc.id, 100, TEST_OPPORTUNITY_STAGENAME_PROSPECTING); 
        List<Contact> contacts = TestDataFactory.createContacts(acc.id, 50);

        Test.startTest();
        insert opps;
        insert contacts;
        for(Opportunity opp: opps) {
            opp.StageName = TEST_OPPORTUNITY_STAGENAME_CLOSEWON;
        }
        update opps;
        Test.stopTest();

        List<OpportunityContactRole> newOppConRoles = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId IN:opps];

        System.assertEquals((opps.size() * contacts.size()), newOppConRoles.size(), 'Count matched on Bulk Update');
    }
}
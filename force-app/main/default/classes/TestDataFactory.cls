/*
* @author : Mani Mahal
* @date : September 29, 2022
*
* @description : Test Data Factory for test records
*/
@isTest
public class TestDataFactory {
    //Account
    public static Account createAccount(Boolean doInsert) {
		return createAccount('testAccount', doInsert);
	}
	
	public static Account createAccount(String name, Boolean doInsert) {
		Account acc = new Account(name = name);
		if(doInsert) {
			insert acc;
		}
		return acc;
	}
	
    //Contact
	public static Contact createContact(Boolean doInsert) {
		Account acc = createAccount(true);
		return createContact('testContact', acc.id, true);
	}
	
	public static Contact createContact(String name, Id accountId, Boolean doInsert) {
		Contact c = new Contact(firstName = name, lastName = name, accountId = accountId);
		if(doInsert) {
			insert c;
		}
		return c;
	}

	public static List<Contact> createContacts(Id accountId, Integer numCons) {
		List<Contact> contacts = new List<Contact>();
		for(Integer i = 1; i <= numCons; i++) {
			Contact c = new Contact();
			c.firstName = 'TestContactFirstName ' + i;
			c.LastName = 'TestContactLastName' + i;
			c.accountId = accountId;
			contacts.add(c);
		}
		return contacts;
	}

    //Opportunity
	public static List<Opportunity> createOpportunity(Id accountId, Integer numOpps, String stageName) {
		List<Opportunity> opps = new List<Opportunity>();
		for(Integer i = 1; i <= numOpps; i++) {
			Opportunity opp = new Opportunity();
			opp.name = 'Account ' + i;
			opp.accountId = accountid;
			opp.amount = 1000;
			opp.closeDate = Date.today().addDays(5);
			opp.stageName = stageName;
			opps.add(opp);
		}
		return opps;
	}
}

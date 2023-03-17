@isTest
public without sharing class Test_LeadTriggerActions {

    @TestSetup
    static void makeData(){

        Profile testProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User();
        testUser.LastName = 'Milton';
        testUser.Alias = 'miltest';
        testUser.Username = 'salesforcehouse3@gmail.com';
        testUser.Email = 'salesforcehouse3@gmail.com';
        testUser.TimeZoneSidKey = 'GMT';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.ProfileId = testProfileId.Id;
        testUser.LanguageLocaleKey = 'en_US';
        insert testUser;

        User testUser2 = new User();
        testUser2.LastName = 'Adriana';
        testUser2.Alias = 'adrtest';
        testUser2.Username = 'rikanelafutbol@hotmail.com';
        testUser2.Email = 'rikanelafutbol@hotmail.com';
        testUser2.TimeZoneSidKey = 'GMT';
        testUser2.LocaleSidKey = 'en_US';
        testUser2.EmailEncodingKey = 'UTF-8';
        testUser2.ProfileId = testProfileId.Id;
        testUser2.LanguageLocaleKey = 'en_US';
        insert testUser2;

    }

    @isTest
    private static void testOwnerAssignment() {
        // Test data setup
        Lead testLead = new Lead();
        testLead.FirstName = 'Test';
        testLead.LastName = 'User';
        testLead.Status = 'New';
        testLead.Building__c = 'TENTEN Wilshire';
        testLead.Phone_1__c = '+573829456638';
        testLead.Email = 'testuser@test.com';
        testLead.Company = 'Initial';

        Lead testLead2 = new Lead();
        testLead2.FirstName = 'Test';
        testLead2.LastName = 'User2';
        testLead2.Status = 'New';
        testLead2.Building__c = 'TENTEN Downtown';
        testLead2.Phone_1__c = '+573829456638';
        testLead2.Email = 'testuser2@test.com';
        testLead2.Company = 'Initial';
    
        // Actual test
        Test.startTest();
        insert testLead;
        insert testLead2;
        Test.stopTest();
    
        // Asserts
        List<AggregateResult> assertResults = [SELECT COUNT(OwnerId), Owner.Name FROM Lead GROUP BY Owner.Name];
        Assert.areEqual(2, assertResults.size(), 'Number of records is incorrect');

    }
    
    @isTest
    private static void stampAndResetDaysInContact() {
        // Test data setup
        Lead testLead = new Lead();
        testLead.FirstName = 'Test';
        testLead.LastName = 'User';
        testLead.Status = 'New';
        testLead.Building__c = 'TENTEN Wilshire';
        testLead.Phone_1__c = '+573829456638';
        testLead.Email = 'testuser@test.com';
        testLead.Company = 'Initial';
        insert testLead;
    
        // Actual test
        Test.startTest();

        testLead.Status = 'Toured';
        update testLead;
    
        Test.stopTest();
    
        Lead assertLead = [SELECT Status, Days_in_Contacted_Status__c, Date_in_Contacted_Status__c FROM Lead LIMIT 1];
        Assert.areEqual('Toured', assertLead.Status, 'Status didn\'t get reset');
        Assert.areEqual(null, assertLead.Days_in_Contacted_Status__c, 'Days_in_Contacted_Status__c didn\'t get reset');
        Assert.areEqual(null, assertLead.Date_in_Contacted_Status__c, 'Date_in_Contacted_Status__c didn\'t get reset');

    }

}
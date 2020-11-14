@isTest(seeAllData=false)
public with sharing class OpportunityLineItemTrigger_Helper_Test {

    @testSetup static void setup() {
        Id pricebookId = Test.getStandardPricebookId();

        List<Opportunity> testOpps = new List<Opportunity>();
        for(Integer i=0;i<2;i++) {
            testOpps.add(new Opportunity(Name = 'TestOpp '+i, CloseDate = System.today(), StageName = 'Prospecting', Pricebook2Id = pricebookId));
        }
        insert testOpps;  

        List<Product2> testProds = new List<Product2>();
        for(Integer i=0;i<2;i++) {
            testProds.add(new Product2(Name = 'Product '+i, Family = 'Hardware'));
        }
        insert testProds;
        
        List<PricebookEntry> testPbes = new List<PricebookEntry>();
        for(Integer i=0;i<2;i++) {
            testPbes.add(new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = testProds[i].Id, UnitPrice = 10000, IsActive = true));
        }
        insert testPbes;

        List<Stock_Count__c> testSCs = new List<Stock_Count__c>();
        for(Integer i=0;i<2;i++) {
            testSCs.add(new Stock_Count__c(Name = 'Stock Count ' + i, Count__c = 1000, Product2__c = testProds[i].Id));
        }
        insert testSCs;
    }

    @isTest
    static void OpportunityLineItemTrigger_Helper_Test_AfterInsertSingle() {
        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'TestOpp 1'];
        Stock_Count__c stockCountRecordBefore = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Name = 'Stock Count 1'];

        OpportunityLineItem newOppLine = new OpportunityLineItem(
            OpportunityId = opportunityRecord.Id,
            Product2Id = [SELECT ID, Name FROM Product2 WHERE Name = 'Product 1'].Id,
            Quantity = 3,
            UnitPrice = 100
        );

        insert newOppLine;

        Stock_Count__c stockCountRecord = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Product2__c = :newOppLine.Product2Id];

        System.assertEquals((stockCountRecordBefore.Count__c - newOppLine.Quantity), stockCountRecord.Count__c);
        System.assertNotEquals((stockCountRecordBefore.Count__c), stockCountRecord.Count__c);

    }

    @isTest
    static void OpportunityLineItemTrigger_Helper_Test_AfterInsertSingleFail() {
        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'TestOpp 1'];
        Stock_Count__c stockCountRecordBefore = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Name = 'Stock Count 1'];

        OpportunityLineItem newOppLine = new OpportunityLineItem(
            OpportunityId = opportunityRecord.Id,
            Product2Id = [SELECT ID, Name FROM Product2 WHERE Name = 'Product 1'].Id,
            Quantity = 3000,
            UnitPrice = 100
        );

        try{
            insert newOppLine;
        }catch (Exception e){
            System.assert(e.getMessage().length() != null);
        }
    }

    @isTest
    static void OpportunityLineItemTrigger_Helper_Test_AfterInsertBulk() {
        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'TestOpp 1'];
        Stock_Count__c stockCountRecordBefore = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Name = 'Stock Count 1'];
        Id prodId = [SELECT ID, Name FROM Product2 WHERE Name = 'Product 1'].Id;

        Integer count = 0;

        List<OpportunityLineItem> newOppLineList = new List<OpportunityLineItem>();
        for(Integer i=0; i<300; i++){
            OpportunityLineItem newOppLine = new OpportunityLineItem(
                OpportunityId = opportunityRecord.Id,
                Product2Id = prodId,
                Quantity = 1,
                UnitPrice = 100
            );
            count +=1;
            newOppLineList.add(newOppLine);
        }
        
        insert newOppLineList;

        Stock_Count__c stockCountRecord = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Name = 'Stock Count 1'];

        System.assertEquals((stockCountRecordBefore.Count__c - count), stockCountRecord.Count__c);
        System.assertNotEquals((stockCountRecordBefore.Count__c), stockCountRecord.Count__c);
    }

    @isTest
    static void OpportunityLineItemTrigger_Helper_Test_AfterInsertProfile() {
        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'TestOpp 1'];
        Stock_Count__c stockCountRecordBefore = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Name = 'Stock Count 1'];
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com.JonathanFoxRed1602');
        System.runAs(u){
            OpportunityLineItem newOppLine = new OpportunityLineItem(
                OpportunityId = opportunityRecord.Id,
                Product2Id = [SELECT ID, Name FROM Product2 WHERE Name = 'Product 1'].Id,
                Quantity = 3,
                UnitPrice = 100
            );
    
            try{
                insert newOppLine;
                Stock_Count__c stockCountRecord = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Product2__c = :newOppLine.Product2Id];
                System.assertEquals((stockCountRecordBefore.Count__c - newOppLine.Quantity), stockCountRecord.Count__c);
                System.assertNotEquals((stockCountRecordBefore.Count__c), stockCountRecord.Count__c);

            }catch(Exception e){
                System.assertEquals(e.getMessage().length(), null);
            }
        }        
    }

    @isTest
    static void OpportunityLineItemTrigger_Helper_Test_AfterUpdateSingle() {
        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'TestOpp 1'];
        Stock_Count__c stockCountRecordBefore = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Name = 'Stock Count 1'];

        OpportunityLineItem newOppLine = new OpportunityLineItem(
            OpportunityId = opportunityRecord.Id,
            Product2Id = [SELECT ID, Name FROM Product2 WHERE Name = 'Product 1'].Id,
            Quantity = 3,
            UnitPrice = 100
        );

        insert newOppLine;

        OpportunityLineItem forUpdateOppLine = [SELECT Id, Quantity FROM OpportunityLineItem WHERE Id = :newOppLine.Id ];
        forUpdateOppLine.Quantity = 10;

        update forUpdateOppLine;

        Stock_Count__c stockCountRecord = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Product2__c = :newOppLine.Product2Id];

        System.assertEquals((stockCountRecordBefore.Count__c - forUpdateOppLine.Quantity), stockCountRecord.Count__c);
        System.assertNotEquals((stockCountRecordBefore.Count__c), stockCountRecord.Count__c);
    }

    @isTest
    static void OpportunityLineItemTrigger_Helper_Test_AfterUpdateSingleFail() {
        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'TestOpp 1'];
        Stock_Count__c stockCountRecordBefore = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Name = 'Stock Count 1'];

        OpportunityLineItem newOppLine = new OpportunityLineItem(
            OpportunityId = opportunityRecord.Id,
            Product2Id = [SELECT ID, Name FROM Product2 WHERE Name = 'Product 1'].Id,
            Quantity = 300,
            UnitPrice = 100
        );

        insert newOppLine;

        OpportunityLineItem forUpdateOppLine = [SELECT Id, Quantity FROM OpportunityLineItem WHERE Id = :newOppLine.Id ];
        forUpdateOppLine.Quantity = 3000;

        try{
            update forUpdateOppLine;
        }catch (Exception e){
            System.assert(e.getMessage().length() != null);
        }
    }

    @isTest
    static void OpportunityLineItemTrigger_Helper_Test_AfterUpdateBulk() {
        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'TestOpp 1'];
        Stock_Count__c stockCountRecordBefore = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Name = 'Stock Count 1'];
        Id prodId = [SELECT ID, Name FROM Product2 WHERE Name = 'Product 1'].Id;

        Integer count = 0;

        List<OpportunityLineItem> newOppLineList = new List<OpportunityLineItem>();
        for(Integer i=0; i<300; i++){
            OpportunityLineItem newOppLine = new OpportunityLineItem(
                OpportunityId = opportunityRecord.Id,
                Product2Id = prodId,
                Quantity = 1,
                UnitPrice = 100
            );
            count +=1;
            newOppLineList.add(newOppLine);
        }
        
        insert newOppLineList;

        for(OpportunityLineItem oppLineItemForUpdate : newOppLineList){
            oppLineItemForUpdate.Quantity = 2;
        }

        update newOppLineList;

        Stock_Count__c stockCountRecord = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Name = 'Stock Count 1'];

        System.assertEquals((stockCountRecordBefore.Count__c - (count*2)), stockCountRecord.Count__c);
        System.assertNotEquals((stockCountRecordBefore.Count__c), stockCountRecord.Count__c);
    }

    @isTest
    static void OpportunityLineItemTrigger_Helper_Test_AfterUpdateProfile() {
        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'TestOpp 1'];
        Stock_Count__c stockCountRecordBefore = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Name = 'Stock Count 1'];
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com.JonathanFoxRed1602');
        

        OpportunityLineItem newOppLine = new OpportunityLineItem(
            OpportunityId = opportunityRecord.Id,
            Product2Id = [SELECT ID, Name FROM Product2 WHERE Name = 'Product 1'].Id,
            Quantity = 3,
            UnitPrice = 100
        );

        insert newOppLine;

        OpportunityLineItem forUpdateOppLine = [SELECT Id, Quantity FROM OpportunityLineItem WHERE Id = :newOppLine.Id ];
        forUpdateOppLine.Quantity = 10;

        System.runAs(u){
            try{
                update forUpdateOppLine;

                Stock_Count__c stockCountRecord = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Product2__c = :newOppLine.Product2Id];

                System.assertEquals((stockCountRecordBefore.Count__c - forUpdateOppLine.Quantity), stockCountRecord.Count__c);
                System.assertNotEquals((stockCountRecordBefore.Count__c), stockCountRecord.Count__c);
            }catch(Exception e){
                System.assertEquals(e.getMessage().length(), null);
            }
        }
    }

    @isTest
    static void OpportunityLineItemTrigger_Helper_Test_AfterDeleteSingle() {
        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'TestOpp 1'];
        Stock_Count__c stockCountRecordBefore = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Name = 'Stock Count 1'];

        OpportunityLineItem newOppLine = new OpportunityLineItem(
            OpportunityId = opportunityRecord.Id,
            Product2Id = [SELECT ID, Name FROM Product2 WHERE Name = 'Product 1'].Id,
            Quantity = 3,
            UnitPrice = 100
        );

        insert newOppLine;

        OpportunityLineItem forDeleteOppLine = [SELECT Id, Quantity FROM OpportunityLineItem WHERE Id = :newOppLine.Id ];
        forDeleteOppLine.Quantity = 10;

        delete forDeleteOppLine;

        Stock_Count__c stockCountRecord = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Product2__c = :newOppLine.Product2Id];

        System.assertEquals((stockCountRecordBefore.Count__c), stockCountRecord.Count__c);
    }

    @isTest
    static void OpportunityLineItemTrigger_Helper_Test_AfterDeleteSingleFail() {
        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'TestOpp 1'];
        Stock_Count__c stockCountRecordBefore = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Name = 'Stock Count 1'];

        OpportunityLineItem newOppLine = new OpportunityLineItem(
            OpportunityId = opportunityRecord.Id,
            Product2Id = [SELECT ID, Name FROM Product2 WHERE Name = 'Product 1'].Id,
            Quantity = 300,
            UnitPrice = 100
        );

        insert newOppLine;

        OpportunityLineItem forDeleteOppLine = [SELECT Id, Quantity FROM OpportunityLineItem WHERE Id = :newOppLine.Id ];
        forDeleteOppLine.Quantity = 3000;

        try{
            delete forDeleteOppLine;
        }catch (Exception e){
            System.assert(e.getMessage().length() != null);
        }
    }

    @isTest
    static void OpportunityLineItemTrigger_Helper_Test_AfterDeleteBulk() {
        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'TestOpp 1'];
        Stock_Count__c stockCountRecordBefore = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Name = 'Stock Count 1'];
        Id prodId = [SELECT ID, Name FROM Product2 WHERE Name = 'Product 1'].Id;

        Integer count = 0;

        List<OpportunityLineItem> newOppLineList = new List<OpportunityLineItem>();
        for(Integer i=0; i<300; i++){
            OpportunityLineItem newOppLine = new OpportunityLineItem(
                OpportunityId = opportunityRecord.Id,
                Product2Id = prodId,
                Quantity = 1,
                UnitPrice = 100
            );
            count +=1;
            newOppLineList.add(newOppLine);
        }
        
        insert newOppLineList;

        for(OpportunityLineItem oppLineItemFordelete : newOppLineList){
            oppLineItemFordelete.Quantity = 2;
        }

        delete newOppLineList;

        Stock_Count__c stockCountRecord = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Name = 'Stock Count 1'];

        System.assertEquals((stockCountRecordBefore.Count__c), stockCountRecord.Count__c);
    }

    @isTest
    static void OpportunityLineItemTrigger_Helper_Test_AfterDeleteProfile() {
        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'TestOpp 1'];
        Stock_Count__c stockCountRecordBefore = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Name = 'Stock Count 1'];
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com.JonathanFoxRed1602');
        

        OpportunityLineItem newOppLine = new OpportunityLineItem(
            OpportunityId = opportunityRecord.Id,
            Product2Id = [SELECT ID, Name FROM Product2 WHERE Name = 'Product 1'].Id,
            Quantity = 3,
            UnitPrice = 100
        );

        insert newOppLine;

        OpportunityLineItem forDeleteOppLine = [SELECT Id, Quantity FROM OpportunityLineItem WHERE Id = :newOppLine.Id ];
        forDeleteOppLine.Quantity = 10;

        System.runAs(u){
            try{
                delete forDeleteOppLine;

                Stock_Count__c stockCountRecord = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Product2__c = :newOppLine.Product2Id];

                System.assertEquals(stockCountRecordBefore.Count__c, stockCountRecord.Count__c);
            }catch(Exception e){
                System.assertEquals(e.getMessage().length(), null);
            }
        }
    }

    @isTest
    static void OpportunityLineItemTrigger_Helper_Test_AfterUndeleteSingle() {
        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'TestOpp 1'];
        Stock_Count__c stockCountRecordBefore = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Name = 'Stock Count 1'];

        OpportunityLineItem newOppLine = new OpportunityLineItem(
            OpportunityId = opportunityRecord.Id,
            Product2Id = [SELECT ID, Name FROM Product2 WHERE Name = 'Product 1'].Id,
            Quantity = 3,
            UnitPrice = 100
        );

        insert newOppLine;
        delete opportunityRecord;

        List<OpportunityLineItem> undeleteOppLine = [SELECT Id FROM OpportunityLineItem ALL ROWS];
        undelete opportunityRecord;

        Stock_Count__c stockCountRecord = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Product2__c = :newOppLine.Product2Id];

        System.assertEquals((stockCountRecordBefore.Count__c - newOppLine.Quantity), stockCountRecord.Count__c);
        System.assertNotEquals((stockCountRecordBefore.Count__c), stockCountRecord.Count__c);

    }

    @isTest
    static void OpportunityLineItemTrigger_Helper_Test_AfterUndeleteSingleFail() {
        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'TestOpp 1'];
        Stock_Count__c stockCountRecordBefore = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Name = 'Stock Count 1'];

        OpportunityLineItem newOppLine = new OpportunityLineItem(
            OpportunityId = opportunityRecord.Id,
            Product2Id = [SELECT ID, Name FROM Product2 WHERE Name = 'Product 1'].Id,
            Quantity = 3000,
            UnitPrice = 100
        );

        try{
            insert newOppLine;
            delete opportunityRecord;
            List<OpportunityLineItem> undeleteOppLine = [SELECT Id FROM OpportunityLineItem ALL ROWS];
            undelete opportunityRecord;
        }catch (Exception e){
            System.assert(e.getMessage().length() != null);
        }
    }

    @isTest
    static void OpportunityLineItemTrigger_Helper_Test_AfterUndeleteBulk() {
        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'TestOpp 1'];
        Stock_Count__c stockCountRecordBefore = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Name = 'Stock Count 1'];
        Id prodId = [SELECT ID, Name FROM Product2 WHERE Name = 'Product 1'].Id;

        Integer count = 0;

        List<OpportunityLineItem> newOppLineList = new List<OpportunityLineItem>();
        for(Integer i=0; i<300; i++){
            OpportunityLineItem newOppLine = new OpportunityLineItem(
                OpportunityId = opportunityRecord.Id,
                Product2Id = prodId,
                Quantity = 1,
                UnitPrice = 100
            );
            count +=1;
            newOppLineList.add(newOppLine);
        }
        
        insert newOppLineList;
        delete opportunityRecord;
        List<OpportunityLineItem> undeleteOppLine = [SELECT Id FROM OpportunityLineItem ALL ROWS];
        undelete opportunityRecord;

        Stock_Count__c stockCountRecord = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Name = 'Stock Count 1'];

        System.assertEquals((stockCountRecordBefore.Count__c - count), stockCountRecord.Count__c);
        System.assertNotEquals((stockCountRecordBefore.Count__c), stockCountRecord.Count__c);
    }

    @isTest
    static void OpportunityLineItemTrigger_Helper_Test_AfterUndeleteProfile() {
        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'TestOpp 1'];
        Stock_Count__c stockCountRecordBefore = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Name = 'Stock Count 1'];
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='sysadmin@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='sysadmin@testorg.com.JonathanFoxRed1602');
        System.runAs(u){
            OpportunityLineItem newOppLine = new OpportunityLineItem(
                OpportunityId = opportunityRecord.Id,
                Product2Id = [SELECT ID, Name FROM Product2 WHERE Name = 'Product 1'].Id,
                Quantity = 3,
                UnitPrice = 100
            );
    
            try{
                insert newOppLine;
                delete opportunityRecord;
                List<OpportunityLineItem> undeleteOppLine = [SELECT Id FROM OpportunityLineItem WHERE isDeleted = true ALL ROWS];
                undelete opportunityRecord;


                Stock_Count__c stockCountRecord = [SELECT Id, Count__c, Product2__c FROM Stock_Count__c WHERE Product2__c = :newOppLine.Product2Id];
                System.assertEquals((stockCountRecordBefore.Count__c - newOppLine.Quantity), stockCountRecord.Count__c);
                System.assertNotEquals((stockCountRecordBefore.Count__c), stockCountRecord.Count__c);

            }catch(Exception e){
                System.assertEquals(e.getMessage().length(), null);
            }
        }        
    }
}
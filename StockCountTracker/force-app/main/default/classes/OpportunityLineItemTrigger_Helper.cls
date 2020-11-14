public with sharing class OpportunityLineItemTrigger_Helper {
    
    public static void OppotunityLineItemTrigger_Helper_afterInsert(List<OpportunityLineItem> OppotunityLineItemList) {

        System.debug('INSERT HELPER');

        List<Stock_Count__c> stockCountRecordsToUpdate = new List<Stock_Count__c>();

        Map<Id, Stock_Count__c> opporunityLineToStockCountMap = getProduct2(OppotunityLineItemList);

        for(OpportunityLineItem oppLine : OppotunityLineItemList){
            Stock_Count__c stockCountRecord = opporunityLineToStockCountMap.get(oppLine.Id);
            stockCountRecord.Count__c -= oppLine.Quantity;
            if(!stockCountRecordsToUpdate.contains(stockCountRecord)){
                stockCountRecordsToUpdate.add(stockCountRecord);
            }
        }
        try{
            update stockCountRecordsToUpdate;
        }catch(Exception e){
            System.debug('An error occurred - ' + e.getMessage());
            System.debug('An error occurred - ' + e.getCause());
            System.debug('An error occurred - ' + e.getLineNumber());
        }
    }

    public static void OppotunityLineItemTrigger_Helper_afterUpdate(List<OpportunityLineItem> newOppotunityLineItemList, List<OpportunityLineItem> oldOppotunityLineItemList) {
        
        System.debug('UPDATE HELPER');

        List<Stock_Count__c> stockCountRecordsToUpdate = new List<Stock_Count__c>();

        Map<Id, Stock_Count__c> opporunityLineToStockCountMap = getProduct2(newOppotunityLineItemList);

        for(OpportunityLineItem newOppLine : newOppotunityLineItemList){
            for(OpportunityLineItem oldOppLine : oldOppotunityLineItemList){
                if((newOppLine.Id == oldOppLine.Id) && (newOppLine.Quantity != oldOppLine.Quantity)){
                    Stock_Count__c stockCountRecord = opporunityLineToStockCountMap.get(newOppLine.Id);

                    if(newOppLine.Quantity > oldOppLine.Quantity){
                        stockCountRecord.Count__c -= (newOppLine.Quantity - oldOppLine.Quantity);
                        if(!stockCountRecordsToUpdate.contains(stockCountRecord)){
                            stockCountRecordsToUpdate.add(stockCountRecord);
                        }
                    }
                    if(newOppLine.Quantity < oldOppLine.Quantity){
                        stockCountRecord.Count__c += (newOppLine.Quantity - oldOppLine.Quantity);
                        if(!stockCountRecordsToUpdate.contains(stockCountRecord)){
                            stockCountRecordsToUpdate.add(stockCountRecord);
                        }
                    }
                }
            }
        }
        try{
            update stockCountRecordsToUpdate;
        }catch(Exception e){
            System.debug('An error occurred - ' + e.getMessage());
            System.debug('An error occurred - ' + e.getCause());
            System.debug('An error occurred - ' + e.getLineNumber());
        }
    }

    public static void OppotunityLineItemTrigger_Helper_afterDelete(List<OpportunityLineItem> OppotunityLineItemList) {

        System.debug('DELETE HELPER');

        List<Stock_Count__c> stockCountRecordsToUpdate = new List<Stock_Count__c>();

        Map<Id, Stock_Count__c> opporunityLineToStockCountMap = getProduct2(OppotunityLineItemList);

        System.debug(OppotunityLineItemList);
        for(OpportunityLineItem oppLine : OppotunityLineItemList){
            System.debug(oppLine);
            Stock_Count__c stockCountRecord = opporunityLineToStockCountMap.get(oppLine.Id);
            stockCountRecord.Count__c += oppLine.Quantity;
            if(!stockCountRecordsToUpdate.contains(stockCountRecord)){
                stockCountRecordsToUpdate.add(stockCountRecord);
            }
        }
        try{
            update stockCountRecordsToUpdate;
        }catch(Exception e){
            System.debug('An error occurred - ' + e.getMessage());
            System.debug('An error occurred - ' + e.getCause());
            System.debug('An error occurred - ' + e.getLineNumber());
        }
    }

    /*** Can not undelete Opportunity Line Items. This is tested by deleteing the Opportunity and then undeleting the Opportunity ***/
    // public static void OppotunityLineItemTrigger_Helper_afterUndelete(List<OpportunityLineItem> OppotunityLineItemList) {

    //     System.debug('UNDELETE HELPER');

    //     List<Stock_Count__c> stockCountRecordsToUpdate = new List<Stock_Count__c>();

    //     Map<Id, Stock_Count__c> opporunityLineToStockCountMap = getProduct2(OppotunityLineItemList);

    //     for(OpportunityLineItem oppLine : OppotunityLineItemList){
    //         Stock_Count__c stockCountRecord = opporunityLineToStockCountMap.get(oppLine.Id);
    //         System.debug(stockCountRecord);
    //         stockCountRecord.Count__c -= oppLine.Quantity;
    //         System.debug(stockCountRecord.Count__c);
    //         if(!stockCountRecordsToUpdate.contains(stockCountRecord)){
    //             stockCountRecordsToUpdate.add(stockCountRecord);
    //             System.debug(stockCountRecord.Count__c);
    //         }
    //     }
    //     try{
    //         update stockCountRecordsToUpdate;
    //     }catch(Exception e){
    //         System.debug('An error occurred - ' + e.getMessage());
    //         System.debug('An error occurred - ' + e.getCause());
    //         System.debug('An error occurred - ' + e.getLineNumber());
    //     }
    // }

    /* Helper method to SOQL once to get the records needed */
    private static Map<Id, Stock_Count__c> getProduct2(List<OpportunityLineItem> OppotunityLineItemList){

       Map<Id, Stock_Count__c> opporunityLineToStockCountMap = new Map<Id, Stock_Count__c>();
       List<Id> oppLineItemP2IDList = new List<Id>();

        for(OpportunityLineItem oppLine : OppotunityLineItemList){
            oppLineItemP2IDList.add(oppLine.Product2Id);
        }

        List<Stock_Count__c> StockCountList = [SELECT Id, Count__c, Product2__c, Product2__r.ID FROM Stock_Count__c WHERE Stock_Count__c.Product2__r.ID in :oppLineItemP2IDList];
        
        for(OpportunityLineItem oppLine : OppotunityLineItemList){
            if(!opporunityLineToStockCountMap.keyset().contains(oppLine.Id)){
                for(Stock_Count__c stockCountRecord : StockCountList){
                    if(stockCountRecord.Product2__r.ID == oppLine.Product2Id)
                    opporunityLineToStockCountMap.put(oppLine.Id, stockCountRecord);
                }
            }
        }
        return opporunityLineToStockCountMap;
    }
}
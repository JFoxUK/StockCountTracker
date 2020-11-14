trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, before update, after insert, after update, before delete, after delete, after undelete) {

    //Query custom setting for this trigger to check if we are bypassing it or not.
    Trigger_Setting__mdt trigSet = [SELECT Id, Active__c FROM Trigger_Setting__mdt WHERE DeveloperName = 'OpportunityLineItemTrigger'];

    //Custom setting check.
    if(trigSet.Active__c == true){
        System.debug('IS ACTIVE');

        //Handle before/after and DML type logic here before passing to helper
        if(Trigger.isBefore){
            System.debug('IS BEFORE');
            if(Trigger.isInsert){
                
            }
            if(Trigger.isUpdate){
                
            }
            if(Trigger.isDelete){

            }
        }

        if(Trigger.isAfter){
            System.debug('IS AFTER');
            if(Trigger.isInsert){
                System.debug('IS INSERT');
                OpportunityLineItemTrigger_Helper.OppotunityLineItemTrigger_Helper_afterInsert(Trigger.new);
            }
            if(Trigger.isUpdate){
                System.debug('IS UPDATE');
                OpportunityLineItemTrigger_Helper.OppotunityLineItemTrigger_Helper_afterUpdate(Trigger.new, Trigger.old);
            }
            if(Trigger.isDelete){
                System.debug('IS DELETE');
                OpportunityLineItemTrigger_Helper.OppotunityLineItemTrigger_Helper_afterDelete(Trigger.old);
            }
            if(Trigger.isUndelete){
                System.debug('IS UNDELETE');
                //Can not undelete Opportunity Line Items. This is tested by deleteing the Opportunity and then undeleting the Opportunity
                //OpportunityLineItemTrigger_Helper.OppotunityLineItemTrigger_Helper_afterUndelete(Trigger.new);
            }
        }
    }
}
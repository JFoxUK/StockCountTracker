# StockCountTracker
Tracks count of stock based on products related to Opportunities via Opportunity Line Items.

Create a Stock__c record per product and allocate the amount of stock in the Count__c field.

Whenever this product is related to an opportunity as an opportunity line item, Count__c field on the Stock__c record will reflect the quatity entered on the opportunity line item.

If inserted, updated, deleted or undeleted, this is reflected by addining or minusing the correct value.

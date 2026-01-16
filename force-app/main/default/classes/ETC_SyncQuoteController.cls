public with sharing class ETC_SyncQuoteController {
    @AuraEnabled(cacheable=false)
    public static Account getAccount(String externalId) {
        List<Account> accounts = [SELECT Id, Name, Cliente__c FROM Account WHERE Cliente__c = :externalId];
        if (accounts.size() > 0) {
            return accounts.get(0);
        } else {
            return new Account();
        }
    }

    @AuraEnabled(cacheable=false)
    public static Opportunity getOpportunity(String identificationCode) {
        if (identificationCode == null) {
            return new Opportunity();
        }
        List<Opportunity> opportunities = [SELECT Id, Name FROM Opportunity WHERE N_mero_de_cotizaci_n__c = :identificationCode OR Id = : identificationCode];
        if (opportunities.size() > 0) {
            return opportunities.get(0);
        } else {
            return new Opportunity();
        }
    }

    @AuraEnabled(cacheable=false)
    public static Quote findQuoteByExternalId(String externalId) {
        List<Quote> quotes = [SELECT Id, Name, N_mero_de_cotizaci_n__c, OpportunityId FROM Quote WHERE N_mero_de_cotizaci_n__c = :externalId];
        if (quotes.size() > 0) {
            return quotes.get(0);
        } else {
            return null;
        }
    }

    @AuraEnabled(cacheable=false)
    public static String generateRecordLink(String recordId) {
        if (recordId == null) {
            return null;
        }
        String recordUrl = URL.getOrgDomainUrl().toExternalForm() + '/' + recordId;
        return recordUrl;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, String> saveQuoteRecord(String rawNewQuoteData) {
        String standardPricebook = Test.isRunningTest() ? Test.getStandardPricebookId() : [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
        Map<String, String> recordLinks = new Map<String, String>();
        ETC_AeiQuoteModel newQuoteData = ETC_AeiQuoteModel.parse(rawNewQuoteData);

        Opportunity newOpp = new Opportunity();
        try {
            if (newQuoteData.data.sfOppId != null) {
                newOpp.Id = newQuoteData.data.sfOppId;
            } else {
                newOpp.Name = newQuoteData.data.MovID;
            }
            newOpp.StageName = 'Qualification';
            newOpp.CloseDate = Date.valueOf(newQuoteData.data.FechaEmision);
            if (newQuoteData.data.sfOppId != null) {
                update newOpp;
            } else {
                newOpp.N_mero_de_cotizaci_n__c = newQuoteData.data.MovID;
                newOpp.AccountId = newQuoteData.data.sfAccountId;
                newOpp.Pricebook2Id = standardPricebook;
                insert newOpp;
            }
            recordLinks.put('opportunityUrl', ETC_SyncQuoteController.generateRecordLink(newOpp.Id));
            recordLinks.put('opportunityCreatedId', newOpp.Id);
        } catch (Exception e) {
            System.debug('New Opp Exception');
            System.debug(e);
            recordLinks.put('error', e.getMessage().split('first error: ')[1]);
            return recordLinks;
        }
        
        Quote newQuote = new Quote();
        try {
            newQuote.Name = newQuoteData.data.MovID;
            newQuote.N_mero_de_cotizaci_n__c = newQuoteData.data.MovID;
            newQuote.Pricebook2Id = standardPricebook;
            newQuote.OpportunityId = newOpp.id;
            upsert newQuote N_mero_de_cotizaci_n__c;
            recordLinks.put('quoteUrl', ETC_SyncQuoteController.generateRecordLink(newQuote.Id));
            List<QuoteLineItem> newQuoteLineItems = new List<QuoteLineItem>();
            for (ETC_AeiQuoteModel.VentaDCta quoteItem: newQuoteData.data.VentaDCta) {
                Product2 productRef = new Product2(External_Id__c=quoteItem.Articulo);
                PricebookEntry pbEntryRef = new PricebookEntry(External_Id__c='mxn_' + quoteItem.Articulo);
                QuoteLineItem newQuoteItem = new QuoteLineItem();
                newQuoteItem.QuoteId = newQuote.Id;
                newQuoteItem.Quantity = quoteItem.Cantidad;
                newQuoteItem.UnitPrice = quoteItem.Precio;
                newQuoteItem.Product2 = productRef;
                newQuoteItem.PricebookEntry = pbEntryRef;
                newQuoteItem.External_Id__c = newQuote.N_mero_de_cotizaci_n__c + '_' + quoteItem.Articulo;
                newQuoteLineitems.add(newQuoteItem);
            }
            upsert newQuoteLineItems External_Id__c;

            // create orders
            Id rejectedOrderRecordType = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Cotizaci_n_perdida').getRecordTypeId();
            Id orderRecordType = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Pedido').getRecordTypeId();

            List<Order> newOrders = new List<Order>();
            List<OrderItem> newOrderLineItems = new List<OrderItem>();
            for (ETC_AeiQuoteModel.DestinoCta orderItem : newQuoteData.data.DestinoCta) {
                Order newOrderRecord = new Order();
                newOrderRecord.Name = orderItem.MovID;
                newOrderRecord.QuoteId = newQuote.Id;
                newOrderRecord.Id_de_Movimiento__c = orderItem.MovID;
                newOrderRecord.AccountId = newQuoteData.data.sfAccountId;
                newOrderRecord.Status = 'Draft';
                newOrderRecord.EffectiveDate = Date.valueOf(orderItem.FechaEmision);
                newOrderRecord.OpportunityId = newOpp.id;
                newOrderRecord.Pricebook2Id = standardPricebook;
                if (orderItem.Mov == 'Cotizacion Perdida') {
                    newOrderRecord.RecordTypeId = rejectedOrderRecordType;
                } else {
                    newOrderRecord.RecordTypeId = orderRecordType;
                }
                newOrders.add(newOrderRecord);
                // create order items
                for (ETC_AeiQuoteModel.DetalleDtoCta orderLine : orderItem.DetalleDtoCta) {
                    Order orderRef = new Order(Id_de_Movimiento__c = orderItem.MovID);
                    QuoteLineItem quoteLineItemRef = new QuoteLineItem(External_Id__c=newQuote.N_mero_de_cotizaci_n__c + '_' + orderLine.Articulo);
                    Product2 productRef = new Product2(External_Id__c=orderLine.Articulo);
                    PricebookEntry pbEntryRef = new PricebookEntry(External_Id__c='mxn_' + orderLine.Articulo);
                    OrderItem newOrderLine = new OrderItem();
                    newOrderLine.Order = orderRef;
                    newOrderLine.Quantity = orderLine.Cantidad;
                    newOrderLine.UnitPrice = orderLine.Precio;
                    newOrderLine.Product2 = productRef;
                    newOrderLine.PricebookEntry = pbEntryRef;
                    newOrderLine.QuoteLineItem = quoteLineItemRef;
                    newOrderLine.External_Id__c = newOrderRecord.Id_de_Movimiento__c + '_' + orderLine.Articulo;
                    newOrderLineitems.add(newOrderLine);
                }
            }
            upsert newOrders Id_de_Movimiento__c;
            upsert newOrderLineItems External_Id__c;

            recordLinks.put('createdOrders', JSON.serialize(newOrders));
        } catch (Exception e) {
            System.debug('New Quote Exception');
            System.debug(e);
            recordLinks.put('error', e.getMessage().split('first error: ')[1]);
            return recordLinks;
        }

        System.debug(recordLinks);

        return recordLinks;
    }
}
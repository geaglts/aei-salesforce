public with sharing class ETC_SyncQuoteController {
    public static Map<String, String> currencyByTag = new Map<String, String>{
        'Dolares' => 'USD',
        'Euros' => 'EUR',
        'Pesos' => 'MXN'};
    public static Id rejectedOrderRecordType = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Cotizaci_n_perdida').getRecordTypeId();
    public static Id orderRecordType = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Pedido').getRecordTypeId();
    public static Id orderAdjustmentRecordType = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Ajuste_de_pedido').getRecordTypeId();
    
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

        if (newQuoteData.data.sfOppId == null) {
            recordLinks.put('error', 'Esta cotización no puede ser creada debido a que no existe una oportunidad, por favor, genere la oportunidad y asigne el código de la cotización correspondiente.');
            return recordLinks;
        }

        
            Opportunity newOpp = new Opportunity();
            try {
                newOpp.Id = newQuoteData.data.sfOppId;
                newOpp.CurrencyIsoCode = currencyByTag.get(newQuoteData.data.Moneda);
                newOpp.StageName = 'Qualification';
                update newOpp;
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
            newQuote.CurrencyIsoCode = currencyByTag.get(newQuoteData.data.Moneda);
            newQuote.N_mero_de_cotizaci_n__c = newQuoteData.data.MovID;
            newQuote.Pricebook2Id = standardPricebook;
            newQuote.OpportunityId = newQuoteData.data.sfOppId;
            newQuote.debug__c = rawNewQuoteData;
            upsert newQuote N_mero_de_cotizaci_n__c;

            newOpp.SyncedQuoteId = newQuote.Id;
            update newOpp;

            recordLinks.put('quoteUrl', ETC_SyncQuoteController.generateRecordLink(newQuote.Id));
            List<QuoteLineItem> newQuoteLineItems = new List<QuoteLineItem>();
            for (ETC_AeiQuoteModel.VentaDCta quoteItem: newQuoteData.data.VentaDCta) {
                Product2 productRef = new Product2(External_Id__c=quoteItem.Articulo);
                PricebookEntry pbEntryRef = new PricebookEntry(External_Id__c=currencyByTag.get(newQuoteData.data.Moneda).toLowerCase() + '_' + quoteItem.Articulo);
                QuoteLineItem newQuoteItem = new QuoteLineItem();
                newQuoteItem.QuoteId = newQuote.Id;
                newQuoteItem.Quantity = quoteItem.Cantidad;
                newQuoteItem.UnitPrice = quoteItem.Precio;
                newQuoteItem.Product2 = productRef;
                newQuoteItem.PricebookEntry = pbEntryRef;

                newQuoteItem.Renglon_Tipo__c = quoteItem.RenglonTipo;
                newQuoteItem.Tho_Codigo_Fabricante__c = quoteItem.ThoCodigoFabricante;
                newQuoteItem.Impuesto1__c = String.valueOf(quoteItem.Impuesto1);
                newQuoteItem.Costo__c = String.valueOf(quoteItem.Costo);
                if (String.isNotBlank(quoteItem.FechaRequerida)) {
                    newQuoteItem.Fecha_Requerida__c = Datetime.valueOf(quoteItem.FechaRequerida.replaceAll('T', ' '));
                }
                newQuoteItem.ContUso2__c = quoteItem.ContUso2;
                newQuoteItem.ThoDescAmpliada__c = quoteItem.ThoDescAmpliada;
                
                newQuoteItem.External_Id__c = newQuoteData.data.MovID + '_' + quoteItem.Renglon;
                newQuoteLineitems.add(newQuoteItem);
            }
            upsert newQuoteLineItems External_Id__c;

            Map<String, List<Object>> ordersToCreate = generateOrderRecordsWithItems(newQuoteData, newQuoteData.data.DestinoCta, newQuote, newOpp, standardPricebook, false);
            List<Order> newOrders = (List<Order>) ordersToCreate.get('orders');
            List<OrderItem> newOrderItems = (List<OrderItem>) ordersToCreate.get('orderItems');
            upsert newOrders Id_de_Movimiento__c;
            upsert newOrderItems External_Id__c;

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

    // Metodo para generar los pedidos de una cotizacion con base a un parametro de entrada
    // Parametro de entrada: Lista de pedidos a generar
    public static Map<String, List<Object>> generateOrderRecordsWithItems(ETC_AeiQuoteModel newQuoteData, ETC_AeiQuoteModel.DestinoCta[] ordersToCreate, Quote newQuote, Opportunity newOpp, String standardPricebook, Boolean isAdjustment) {
        Map<String, List<Object>> outputRecords = new Map<String, List<Object>>();
        
        List<Order> newOrders = new List<Order>();
        List<OrderItem> newOrderLineItems = new List<OrderItem>();
        for (ETC_AeiQuoteModel.DestinoCta orderItem : ordersToCreate) {
            System.debug('-------------------------');
            System.debug(isAdjustment);
            System.debug(orderItem);
            System.debug('-------------------------');
            Order newOrderRecord = new Order();
            newOrderRecord.Name = orderItem.MovID;
            newOrderRecord.CurrencyIsoCode = currencyByTag.get(newQuoteData.data.Moneda);
            newOrderRecord.QuoteId = newQuote.Id;
            newOrderRecord.Id_de_Movimiento__c = orderItem.MovID;
            newOrderRecord.AccountId = newQuoteData.data.sfAccountId;
            newOrderRecord.Status = orderItem.Estatus;
            newOrderRecord.Tipo_de_movimiento_bandera__c = orderItem.Mov;
            if (orderItem.Mov == 'Ajuste Pedido' && orderItem.OrigenID != null) {
                newOrderRecord.Movimiento_origen__r = new Order(Id_de_Movimiento__c = orderItem.OrigenID);
            }
            if (orderItem.FechaEmision != null) {
                newOrderRecord.EffectiveDate = Date.valueOf(orderItem.FechaEmision);
            }   
            newOrderRecord.OpportunityId = newOpp.id;
            newOrderRecord.Pricebook2Id = standardPricebook;
            if (orderItem.Mov == 'Cotizacion Perdida') {
                newOrderRecord.RecordTypeId = rejectedOrderRecordType;
            } else if (orderItem.Mov == 'Ajuste Pedido') {
                newOrderRecord.RecordTypeId = orderAdjustmentRecordType;
            } else {
                newOrderRecord.RecordTypeId = orderRecordType;
            }
            newOrders.add(newOrderRecord);
            // create order items
            ETC_AeiQuoteModel.DetalleDtoCta[] orderItemsToSave;
            if (isAdjustment) {
                orderItemsToSave = orderItem.DestDetPedidoCte;
            } else {
                orderItemsToSave = orderItem.DetalleDtoCta;
            }
            for (ETC_AeiQuoteModel.DetalleDtoCta orderLine : orderItemsToSave) {
                Order orderRef = new Order(Id_de_Movimiento__c = orderItem.MovID);
                QuoteLineItem quoteLineItemRef = new QuoteLineItem(External_Id__c=newQuote.N_mero_de_cotizaci_n__c + '_' + orderLine.AplicaRenglon);
                Product2 productRef = new Product2(External_Id__c=orderLine.Articulo);
                PricebookEntry pbEntryRef = new PricebookEntry(External_Id__c=currencyByTag.get(newQuoteData.data.Moneda).toLowerCase() + '_' + orderLine.Articulo);
                OrderItem newOrderLine = new OrderItem();
                newOrderLine.Order = orderRef;
                newOrderLine.Quantity = orderLine.Cantidad;
                newOrderLine.UnitPrice = orderLine.Precio;
                newOrderLine.Product2 = productRef;
                newOrderLine.PricebookEntry = pbEntryRef;
                newOrderLine.QuoteLineItem = quoteLineItemRef;
                newOrderLine.External_Id__c = newOrderRecord.Id_de_Movimiento__c + '_' + orderLine.Articulo + '_' + orderLine.AplicaRenglon;
                newOrderLineitems.add(newOrderLine);
            }

            if (orderItem.DestPedidoCte != null) {
                Map<String, List<Object>> adjustmentOrders = generateOrderRecordsWithItems(newQuoteData, orderItem.DestPedidoCte, newQuote, newOpp, standardPricebook, true);
                List<Order> adjustedOrders = (List<Order>) adjustmentOrders.get('orders');
                List<OrderItem> adjustedOrderItems = (List<OrderItem>) adjustmentOrders.get('orderItems');
                
                newOrders.addAll(adjustedOrders);
                newOrderLineItems.addAll(adjustedOrderItems);
            }

        }

        outputRecords.put('orders', newOrders);
        outputRecords.put('orderItems', newOrderLineItems);

        return outputRecords;
    }
}
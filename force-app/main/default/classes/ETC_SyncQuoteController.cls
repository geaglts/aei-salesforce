public with sharing class ETC_SyncQuoteController {
    public static Map<String, String> currencyByTag = new Map<String, String>{
        'Dolares' => 'USD',
        'Euros' => 'EUR',
        'Pesos' => 'MXN'};

    public static Map<String, Id> recordTypeForOrder = new Map<String, Id>{
        'cotizacion perdida' => Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Cotizaci_n_perdida').getRecordTypeId(),
        'ajuste pedido' => Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Ajuste_de_pedido').getRecordTypeId(),
        'cotizacion rechazada' => Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Cotizaci_n_rechazada').getRecordTypeId(),
        'default' => Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Pedido').getRecordTypeId(),
        'venta perdida' => Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Venta_perdida').getRecordTypeId(),
        'venta rechazada' => Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Venta_rechazada').getRecordTypeId()
    };

    public static String DEFAULT_OWNER;
    
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
        Map<String, String> ownersByAgent = ETC_Utility.getUserIdByAgentCode();
        String standardPricebook = Test.isRunningTest() ? Test.getStandardPricebookId() : [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
        Map<String, String> recordLinks = new Map<String, String>();
        ETC_AeiQuoteModel newQuoteData = ETC_AeiQuoteModel.parse(rawNewQuoteData);

        // if (newQuoteData.data.sfOppId == null) {
        //     recordLinks.put('error', 'Esta cotización no puede ser creada debido a que no existe una oportunidad, por favor, genere la oportunidad y asigne el código de la cotización correspondiente.');
        //     return recordLinks;
        // }

        Opportunity newOpp = new Opportunity();
        if (ownersByAgent.containsKey(newQuoteData.data.Agente)) {
            ETC_SyncQuoteController.DEFAULT_OWNER = ownersByAgent.get(newQuoteData.data.Agente);
        } else {
            ETC_SyncQuoteController.DEFAULT_OWNER = ownersByAgent.get(ETC_GetAccountsWs.defaultOwner());
        }
        try {
            if (String.isBlank(newQuoteData.data.sfOppId)) {
                newOpp.Name = newQuoteData.data.MovID;
                newOpp.CloseDate = Date.valueOf(newQuoteData.data.FechaEmision);
                newOpp.CurrencyIsoCode = currencyByTag.get(newQuoteData.data.Moneda);
                newOpp.Account = new Account(Cliente__c = newQuoteData.data.Cliente);
            }
            newOpp.OwnerId = ETC_SyncQuoteController.DEFAULT_OWNER;
            newOpp.N_mero_de_cotizaci_n__c = newQuoteData.data.MovID;
            if (newQuoteData.data.EtapaOportunidad.size() > 0) {
                newOpp.StageName = newQuoteData.data.EtapaOportunidad[0].EtapaOportunidad;
            }
            System.debug(newOpp);
            upsert newOpp N_mero_de_cotizaci_n__c;
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
            newQuote.OwnerId = ETC_SyncQuoteController.DEFAULT_OWNER;
            newQuote.CurrencyIsoCode = currencyByTag.get(newQuoteData.data.Moneda);
            newQuote.N_mero_de_cotizaci_n__c = newQuoteData.data.MovID;
            newQuote.Status = newQuoteData.data.Estatus;
            newQuote.Pricebook2Id = standardPricebook;
            if (newQuoteData.data.SucursalCta.size() > 0) {
                newQuote.Sucursal__r = new Sucursal__c(External_Id__c = String.valueOf(newQuoteData.data.SucursalCta[0].Sucursal));
            }
            newQuote.OpportunityId = newOpp.Id;
            newQuote.debug__c = rawNewQuoteData;
            upsert newQuote N_mero_de_cotizaci_n__c;

            // newOpp.SyncedQuoteId = newQuote.Id;
            // update newOpp;

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
            List<Order> newChildrenOrders = (List<Order>) ordersToCreate.get('chidlrenOrders');
            List<OrderItem> newOrderItems = (List<OrderItem>) ordersToCreate.get('orderItems');

            // System.debug(JSON.serializePretty(newOrders));

            upsert newOrders Id_de_Movimiento__c;
            upsert newChildrenOrders Id_de_Movimiento__c;
            upsert newOrderItems External_Id__c;

			// Database.UpsertResult[] orderResults = Database.upsert(newOrders, Order.Fields.Id_de_Movimiento__c, false);
			// Database.UpsertResult[] childrenOrderResults = Database.upsert(newChildrenOrders, Order.Fields.Id_de_Movimiento__c, false);
			// Database.UpsertResult[] orderItemResults = Database.upsert(newOrderItems, OrderItem.Fields.External_Id__c, false);

			// List<Integer> upOrderResults = ETC_Utility.showQueueResult(orderResults, 'Pedidos', 0 - 1, false);
			// System.debug('Se procesaron: ' + upOrderResults[0] + ' Registros exitosos. Pedidos');
			// System.debug('Se procesaron: ' + upOrderResults[1] + ' Registros con errores. Pedidos');
			
            // List<Integer> upChildrenOrderResults = ETC_Utility.showQueueResult(childrenOrderResults, 'Pedidos Hijos', 0 - 1, false);
			// System.debug('Se procesaron: ' + upChildrenOrderResults[0] + ' Registros exitosos. Pedidos Hijos');
			// System.debug('Se procesaron: ' + upChildrenOrderResults[1] + ' Registros con errores. Pedidos Hijos');

			// List<Integer> upOrderItemResults = ETC_Utility.showQueueResult(orderItemResults, 'Productos de pedido', 0 - 1, false);
			// System.debug('Se procesaron: ' + upOrderItemResults[0] + ' Registros exitosos. Productos de pedido');
			// System.debug('Se procesaron: ' + upOrderItemResults[1] + ' Registros con errores. Productos de pedido');

            newOrders.addAll(newChildrenOrders);

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
        List<Order> newChildrenOrders = new List<Order>();
        List<OrderItem> newOrderLineItems = new List<OrderItem>();
        for (ETC_AeiQuoteModel.DestinoCta orderItem : ordersToCreate) {
            if (orderItem.Mov == 'Remision' || String.isBlank(orderItem.MovID)) {
                break;
            }
            System.debug('-------------------------');
            System.debug(isAdjustment);
            System.debug(orderItem);
            System.debug('-------------------------');
            Order newOrderRecord = new Order();
            newOrderRecord.Name = orderItem.MovID;
            newOrderRecord.OwnerId = ETC_SyncQuoteController.DEFAULT_OWNER;
            newOrderRecord.CurrencyIsoCode = currencyByTag.get(newQuoteData.data.Moneda);
            newOrderRecord.QuoteId = newQuote.Id;
            newOrderRecord.Id_de_Movimiento__c = orderItem.MovID;
            newOrderRecord.Account = new Account(Cliente__c = newQuoteData.data.Cliente);
            newOrderRecord.Status = orderItem.Estatus;
            newOrderRecord.Tipo_de_movimiento_bandera__c = orderItem.Mov;
            if (orderItem.Origen == 'Pedido' && orderItem.OrigenID != null) {
                newOrderRecord.Movimiento_origen__r = new Order(Id_de_Movimiento__c = orderItem.OrigenID);
            }
            if (orderItem.FechaEmision != null) {
                newOrderRecord.EffectiveDate = Date.valueOf(orderItem.FechaEmision);
            }   
            newOrderRecord.OpportunityId = newOpp.id;
            newOrderRecord.Pricebook2Id = standardPricebook;
            if (recordTypeForOrder.containsKey(orderItem.Mov.toLowerCase())) {
                newOrderRecord.RecordTypeId = recordTypeForOrder.get(orderItem.Mov.toLowerCase());
            } else {
                newOrderRecord.RecordTypeId = recordTypeForOrder.get('default');
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
                Product2 productRef = new Product2(External_Id__c=orderLine.Articulo);
                // System.debug(newOrderRecord.CurrencyIsoCode);
                PricebookEntry pbEntryRef = new PricebookEntry(External_Id__c=currencyByTag.get(newQuoteData.data.Moneda).toLowerCase() + '_' + orderLine.Articulo);
                // System.debug(currencyByTag.get(newQuoteData.data.Moneda).toLowerCase() + '_' + orderLine.Articulo);
                OrderItem newOrderLine = new OrderItem();
                newOrderLine.Order = orderRef;
                newOrderLine.Quantity = orderLine.Cantidad;
                newOrderLine.UnitPrice = orderLine.Precio;
                newOrderLine.Product2 = productRef;
                newOrderLine.PricebookEntry = pbEntryRef;

                if (String.isNotBlank(String.valueOf(orderLine.AplicaRenglon))) {
                    QuoteLineItem quoteLineItemRef = new QuoteLineItem(External_Id__c=newQuote.N_mero_de_cotizaci_n__c + '_' + orderLine.AplicaRenglon);
                    newOrderLine.QuoteLineItem = quoteLineItemRef;
                    newOrderLine.External_Id__c = newOrderRecord.Id_de_Movimiento__c + '_' + orderLine.Articulo + '_' + orderLine.AplicaRenglon;
                } else {
                    newOrderLine.External_Id__c = newOrderRecord.Id_de_Movimiento__c + '_' + orderLine.Articulo + '_' + orderLine.OrigenTipo;
                }
                newOrderLineitems.add(newOrderLine);
            }

            if (orderItem.DestPedidoCte != null) {
                Map<String, List<Object>> adjustmentOrders = generateOrderRecordsWithItems(newQuoteData, orderItem.DestPedidoCte, newQuote, newOpp, standardPricebook, true);
                List<Order> adjustedOrders = (List<Order>) adjustmentOrders.get('orders');
                List<OrderItem> adjustedOrderItems = (List<OrderItem>) adjustmentOrders.get('orderItems');
                
                newChildrenOrders.addAll(adjustedOrders);
                newOrderLineItems.addAll(adjustedOrderItems);
            }

        }

        outputRecords.put('orders', newOrders);
        outputRecords.put('chidlrenOrders', newChildrenOrders);
        outputRecords.put('orderItems', newOrderLineItems);

        return outputRecords;
    }
}
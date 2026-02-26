/*
ETC_ControllerGetQuotes controller = new ETC_ControllerGetQuotes();
controller.sync(ETC_GetQuoteWs.getByPage(1));
*/
public virtual with sharing class ETC_ControllerGetQuotes {
    public List<Opportunity> quoteOpportunity;
    public List<Quote> quotes;
    public List<QuoteLineItem> quoteLineItems;
    public List<Order> orders;
    public List<Order> childrenOrders;
    public List<OrderItem> orderItems;
    public String standardPricebookId;
    public String DEFAULT_USER;
    // maps
    public static Map<String, String> currencyByTag = new Map<String, String>{
        'Dolares' => 'USD',
        'Euros' => 'EUR',
        'Pesos' => 'MXN'};
	public Map<String, String> usersByAgentCode;
    
    public ETC_ControllerGetQuotes() {
        this.quoteOpportunity = new List<Opportunity>();
        this.quotes = new List<Quote>();
        this.quoteLineItems = new List<QuoteLineItem>();
        this.orders = new List<Order>();
        this.childrenOrders = new List<Order>();
        this.orderItems = new List<OrderItem>();
        this.usersByAgentCode = new Map<String, String>();
    }

    public void setGlobalParams(String pricebookId, Map<String, String> usersByAgentCode) {
        this.standardPricebookId = pricebookId;
        this.usersByAgentCode = usersByAgentCode;
    }

    public void sync(ETC_QuoteListResponseModel serviceResponse) {
        buildSObject(serviceResponse.data);
    }

    public void buildSObject(List<ETC_QuoteListResponseModel.Data> quotes) {
        for (ETC_QuoteListResponseModel.Data quoteRecord : quotes) {
            buildSObjectQuote(quoteRecord);
        }
    }
    
    public void buildSObjectQuote(ETC_QuoteListResponseModel.Data quoteRecord) {
        // system.debug('===========+++++++++++++++++++++++++++++===========');
        // system.debug('LOG: quoteRecord' +  quoteRecord);
        // system.debug('===========+++++++++++++++++++++++++++++===========');
        Quote newQuote = new Quote();
        String quoteExternalId = '';
        if (String.isBlank(quoteRecord.MovID)) {
            quoteExternalId = String.valueOf(quoteRecord.ID);
        } else {
            quoteExternalId = quoteRecord.MovID;
        }
        newQuote.Name = quoteExternalId;
        newQuote.CurrencyIsoCode = currencyByTag.get(quoteRecord.Moneda);
        // external id field
        newQuote.N_mero_de_cotizaci_n__c = quoteExternalId;
        newQuote.Pricebook2Id = this.standardPricebookId;
        if (quoteRecord.SucursalCta.size() > 0) {
            newQuote.Sucursal__r = new Sucursal__c(External_Id__c = String.valueOf(quoteRecord.SucursalCta[0].Sucursal));
        }
        newQuote.Opportunity = new Opportunity(N_mero_de_cotizaci_n__c = quoteExternalId);
        newQuote.Status = quoteRecord.Estatus;
        // newQuote.debug__c = JSON.serialize(quoteRecord);
        if (quoteRecord.etapaoportunidad != null && quoteRecord.etapaoportunidad.size() > 0) {
            newQuote.TotalLineas__c = quoteRecord.etapaoportunidad[0].TotalLineas;
            newQuote.LineasPendientes__c = quoteRecord.etapaoportunidad[0].LineasPendientes;
            newQuote.LineasPedido__c = quoteRecord.etapaoportunidad[0].LineasPedido;
            newQuote.LineasPerdidas__c = quoteRecord.etapaoportunidad[0].LineasPerdidas;
            newQuote.LineasRechazadas__c = quoteRecord.etapaoportunidad[0].LineasRechazadas;
        }

        // TODO: Get current user to set in owner record
        String ownerId = '';
        if (usersByAgentCode.containsKey(quoteRecord.Agente)) {
            ownerId = usersByAgentCode.get(quoteRecord.Agente);
        } else {
            ownerId = usersByAgentCode.get(DEFAULT_USER);
        }

        newQuote.OwnerId = ownerId;

        quotes.add(newQuote);

        buildSObjectOpportunity(quoteRecord, quoteExternalId, ownerId);

        for (ETC_QuoteListResponseModel.Ventadcta quoteItem: quoteRecord.ventadcta) {
            buildSObjectQuoteItem(quoteItem, quoteExternalId, currencyByTag.get(quoteRecord.Moneda));
        }

        if (quoteRecord.DestinoCta.size() > 0) {
            // System.debug(quoteRecord.DestinoCta);
            buildSObjectOrder(quoteRecord, quoteRecord.DestinoCta, quoteExternalId, ownerId);
        }
    }

    public void buildSObjectOpportunity(ETC_QuoteListResponseModel.Data quoteRecord, String quoteExternalId, String ownerId) {
        Opportunity newOpp = new Opportunity();

        newOpp.Name = quoteExternalId;
        newOpp.OwnerId = ownerId;
        newOpp.Account = new Account(Cliente__c = quoteRecord.Cliente);
        if (String.isNotBlank(quoteRecord.FechaEmision)) {
            newOpp.CloseDate = Date.valueOf(quoteRecord.FechaEmision);
        }
        if (quoteRecord.etapaoportunidad != null && quoteRecord.etapaoportunidad.size() > 0) {
            newOpp.StageName = quoteRecord.etapaoportunidad[0].EtapaOportunidad;
        }
        newOpp.CurrencyIsoCode = currencyByTag.get(quoteRecord.Moneda);
        // external id field
        newOpp.N_mero_de_cotizaci_n__c = quoteExternalId;
        
        quoteOpportunity.add(newOpp);
    }


    public void buildSObjectQuoteItem(ETC_QuoteListResponseModel.Ventadcta quoteItem, String quoteExternalId, String moneda) {
        Product2 productRef = new Product2(External_Id__c=quoteItem.Articulo);
        PricebookEntry pbEntryRef = new PricebookEntry(External_Id__c=moneda.toLowerCase() + '_' + quoteItem.Articulo);

        QuoteLineItem newQuoteItem = new QuoteLineItem();
        newQuoteItem.Quote = new Quote(N_mero_de_cotizaci_n__c = quoteExternalId);
        if (String.isBlank(String.valueOf(quoteItem.Cantidad)) || quoteItem.Cantidad == 0) {
            // System.debug(quoteExternalId);
            // System.debug(quoteItem.Cantidad);
            return;
        } else {
            newQuoteItem.Quantity = quoteItem.Cantidad;
        }
        if (quoteItem.Precio != null) {
            newQuoteItem.UnitPrice = quoteItem.Precio;
        } else {
            newQuoteItem.UnitPrice = 0;
        }
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
        // external id field
        newQuoteItem.External_Id__c = quoteExternalId + '_' + quoteItem.Renglon;
        
        quoteLineItems.add(newQuoteItem);
    }

    
    public void buildSObjectOrder(ETC_QuoteListResponseModel.Data newQuoteData, ETC_QuoteListResponseModel.DestinoCta[] ordersToCreate, String quoteExternalId, String ownerId) {
        Map<String, List<Object>> orderRecordsToCreate = generateOrderRecordsWithItems(newQuoteData, ordersToCreate, this.standardPricebookId, false, quoteExternalId, ownerId);        
        this.orders.addAll((List<Order>) orderRecordsToCreate.get('orders'));        
        this.childrenOrders.addAll((List<Order>) orderRecordsToCreate.get('childrenOrders'));        
        this.orderItems.addAll((List<OrderItem>) orderRecordsToCreate.get('orderItems'));
    }

    /*Order,OrderItem*/
    // Metodo para generar los pedidos de una cotizacion con base a un parametro de entrada
    // Parametro de entrada: Lista de pedidos a generar
    public static Map<String, List<Object>> generateOrderRecordsWithItems(ETC_QuoteListResponseModel.Data newQuoteData, ETC_QuoteListResponseModel.DestinoCta[] ordersToCreate, String standardPricebook, Boolean isAdjustment, String quoteExternalId, String ownerId) {
        Map<String, List<Object>> outputRecords = new Map<String, List<Object>>();
        
        List<Order> newOrders = new List<Order>();
        List<Order> newChildrenOrders = new List<Order>();
        List<OrderItem> newOrderLineItems = new List<OrderItem>();
        for (ETC_QuoteListResponseModel.DestinoCta orderItem : ordersToCreate) {
            if (orderItem.Mov == 'Remision' || String.isBlank(orderItem.MovID)) {
                break;
            }
            // System.debug('-------------------------');
            // System.debug(isAdjustment);
            // System.debug(orderItem);
            // System.debug('-------------------------');
            Order newOrderRecord = new Order();
            newOrderRecord.OwnerId = ownerId;
            newOrderRecord.Name = orderItem.MovID;
            newOrderRecord.CurrencyIsoCode = currencyByTag.get(newQuoteData.Moneda);
            newOrderRecord.Quote = new Quote(N_mero_de_cotizaci_n__c = quoteExternalId);
            newOrderRecord.Id_de_Movimiento__c = orderItem.MovID;
            newOrderRecord.Account = new Account(Cliente__c = newQuoteData.Cliente);
            newOrderRecord.Status = orderItem.Estatus;
            newOrderRecord.Tipo_de_movimiento_bandera__c = orderItem.Mov;
            if (orderItem.Origen == 'Pedido' && orderItem.OrigenID != null) {
                newOrderRecord.Movimiento_origen__r = new Order(Id_de_Movimiento__c = orderItem.OrigenID);
            }
            if (orderItem.FechaEmision != null) {
                newOrderRecord.EffectiveDate = Date.valueOf(orderItem.FechaEmision);
            }   
            newOrderRecord.Opportunity = new Opportunity(N_mero_de_cotizaci_n__c = quoteExternalId);
            newOrderRecord.Pricebook2Id = standardPricebook;
            if (ETC_SyncQuoteController.recordTypeForOrder.containsKey(orderItem.Mov.toLowerCase())) {
                newOrderRecord.RecordTypeId = ETC_SyncQuoteController.recordTypeForOrder.get(orderItem.Mov.toLowerCase());
            } else {
                newOrderRecord.RecordTypeId = ETC_SyncQuoteController.recordTypeForOrder.get('default');
            }
            newOrders.add(newOrderRecord);
            // create order items
            ETC_QuoteListResponseModel.DetalleDtoCta[] orderItemsToSave;
            if (isAdjustment) {
                orderItemsToSave = orderItem.DestDetPedidoCte;
            } else {
                orderItemsToSave = orderItem.DetalleDtoCta;
            }
            for (ETC_QuoteListResponseModel.DetalleDtoCta orderLine : orderItemsToSave) {
                Order orderRef = new Order(Id_de_Movimiento__c = orderItem.MovID);
                Product2 productRef = new Product2(External_Id__c=orderLine.Articulo);
                PricebookEntry pbEntryRef = new PricebookEntry(External_Id__c=currencyByTag.get(newQuoteData.Moneda).toLowerCase() + '_' + orderLine.Articulo);
                
                OrderItem newOrderLine = new OrderItem();
                newOrderLine.Order = orderRef;
                newOrderLine.Quantity = orderLine.Cantidad;
                newOrderLine.UnitPrice = orderLine.Precio;
                newOrderLine.Product2 = productRef;
                newOrderLine.PricebookEntry = pbEntryRef;
                if (String.isNotBlank(String.valueOf(orderLine.AplicaRenglon))) {
                    QuoteLineItem quoteLineItemRef = new QuoteLineItem(External_Id__c=quoteExternalId + '_' + orderLine.AplicaRenglon);
                    newOrderLine.QuoteLineItem = quoteLineItemRef;
                    newOrderLine.External_Id__c = newOrderRecord.Id_de_Movimiento__c + '_' + orderLine.Articulo + '_' + orderLine.AplicaRenglon;
                } else {
                    newOrderLine.External_Id__c = newOrderRecord.Id_de_Movimiento__c + '_' + orderLine.Articulo + '_' + orderLine.OrigenTipo;
                }
                newOrderLineitems.add(newOrderLine);
            }

            if (orderItem.DestPedidoCte != null) {
                Map<String, List<Object>> adjustmentOrders = generateOrderRecordsWithItems(newQuoteData, orderItem.DestPedidoCte, standardPricebook, true, quoteExternalId, ownerId);
                List<Order> adjustedOrders = (List<Order>) adjustmentOrders.get('orders');
                List<OrderItem> adjustedOrderItems = (List<OrderItem>) adjustmentOrders.get('orderItems');
                
                newChildrenOrders.addAll(adjustedOrders);
                newOrderLineItems.addAll(adjustedOrderItems);
            }

        }

        outputRecords.put('orders', newOrders);
        outputRecords.put('childrenOrders', newChildrenOrders);
        outputRecords.put('orderItems', newOrderLineItems);

        return outputRecords;
    }
}
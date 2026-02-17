public class ETC_QuoteListResponseModel {
    public Meta meta;
    public List<Data> data;

    public class Meta {
        public Decimal page; // 1
        public Decimal limit_cst; // 100
    }

    public class Data {
        public Decimal ID; // 268147
        public Decimal Sucursal; // 2
        public String Cliente; // "CRM0000891"
        public String NomProspecto;
        public String TelProspecto;
        public String EmailProspecto;
        public String Mov; // "Cotizacion"
        public String MovID;
        public String FechaEmision; // "2026-02-17T00:00:00.000Z"
        public String FechaOriginal; // "2026-02-24T09:55:00.000Z"
        public String Concepto; // "Compra"
        public String Referencia;
        public String Observaciones;
        public String Almacen; // "01CARMEN"
        public String Moneda; // "Pesos"
        public Double TipoCambio; // 1
        public String Agente; // "HGUTIERREZ"
        public String Usuario; // "HGUTIERREZ"
        public String Estatus; // "SINAFECTAR"
        public String FormaEnvio;
        public String Condicion;
        public String ListaPreciosEsp; // "V.Gral Carmen MXN"
        public String ZonaImpuesto;
        public List<Sucursalcta> sucursalcta;
        public List<Clientecta> clientecta;
        public List<DestinoCta> destinocta;
        public List<Ventadcta> ventadcta;
        public List<Etapaoportunidad> etapaoportunidad;
    }

    public class DestinoCta {
        @AuraEnabled
        public Integer ID; // 995
        @AuraEnabled
        public String Mov; // "Pedido"
        @AuraEnabled
        public String MovID; // "CAR92"
        @AuraEnabled
        public List<DestinoCta> DestPedidoCte;
        @AuraEnabled
        public String FechaEmision; // "2022-05-03T00:00:00"
        @AuraEnabled
        public String Origen; // "Cotizacion"
        @AuraEnabled
        public String OrigenID; // "CAR13"
        @AuraEnabled
        public String Agente; // "HRODRIGUEZ"
        @AuraEnabled
        public String Estatus; // "CONCLUIDO"
        @AuraEnabled
        public String Moneda; // "Pesos"
        @AuraEnabled
        public Double TipoCambio; // 1
        @AuraEnabled
        public List<DetalleDtoCta> DetalleDtoCta;
        @AuraEnabled
        public List<DetalleDtoCta> DestDetPedidoCte;
    }

    public class DetalleDtoCta {
        @AuraEnabled
        public String Aplica; // "Cotizacion"
        @AuraEnabled
        public String AplicaID; // "CAR13"
        @AuraEnabled
        public Integer AplicaRenglon; // 2048
        @AuraEnabled
        public String Articulo; // "EL-AEC0-0041"
        @AuraEnabled
        public String ClaveFabricante; // "UR-3X12-AR"
        @AuraEnabled
        public String Unidad; // "ML"
        @AuraEnabled
        public Integer Cantidad; // 600
        @AuraEnabled
        public Double Precio; // 43.59
        @AuraEnabled
        public Integer Impuesto1; // 16
        @AuraEnabled
        public Double Costo; // 34.6255
        @AuraEnabled
        public String ContUso2; // "10"
        @AuraEnabled
        public Double Importe; // 26154
    }

    public class Sucursalcta {
        public Decimal Sucursal; // 2
        public String Nombre; // "CARMEN"
        public String Prefijo; // "CAR  "
        public String Direccion; // "Calle 20-A entre 47 y 49"
        public String DireccionNumero; // "14"
        public String Delegacion; // "Carmen"
        public String Colonia; // "Pallas"
        public String Poblacion; // "Ciudad del Carmen"
        public String Estado; // "Campeche"
        public String CodigoPostal; // "24140"
        public String RFC; // "AEI861027P26"
    }

    public class Clientecta {
        public String Nombre; // "ON ENERGY SOLUTIONS"
        public String Direccion; // ""
        public String DireccionNumero; // ""
        public String Delegacion; // "Guadalajara"
        public String Colonia; // "Residencial Juan Manuel"
        public String Poblacion; // "Guadalajara"
        public String Estado; // "Jalisco"
        public String CodigoPostal; // "44680"
        public String RFC; // "OES200914RX4"
    }

    public class Ventadcta {
        public Decimal Renglon; // 2048
        public String RenglonTipo; // "N"
        public String Articulo; // "EL-SEM0-GEN"
        public String DescArt; // "QO CENTRO DE CARGA ML 200A, 1F-3H, 30P MODELO ...
        public String Unidad; // "PZ"
        public String ThoCodigoFabricante; // "EL-SEM0-GEN"
        public Decimal Cantidad; // 1
        public Decimal Precio; // 8607.22
        public Decimal DescuentoImporte; // 0
        public Decimal Impuesto1; // 16
        public Decimal Costo; // 0
        public String ContUso2; // "10"
        public String FechaRequerida; // "2026-03-31T00:00:00"
        public Boolean ThoDescAmpliada; // true
    }

    public class Etapaoportunidad {
        public String Estatus; // "SINAFECTAR"
        public Decimal TotalLineas; // 2
        public Decimal LineasPendientes; // 2
        public Decimal LineasPedido; // 0
        public Decimal LineasPerdidas; // 0
        public Decimal LineasRechazadas; // 0
        public String EtapaOportunidad; // "Propuesta Financiera"
    }

    public static ETC_QuoteListResponseModel parse(String jsonString) {
        jsonString = jsonString.replace('"limit"', '"limit_cst"');
        system.debug('===========+++++++++++++++++++++++++++++===========');
        system.debug('LOG: jsonString' +  jsonString);
        system.debug('===========+++++++++++++++++++++++++++++===========');
        return (ETC_QuoteListResponseModel) JSON.deserialize(jsonString, ETC_QuoteListResponseModel.class);
    }
}
